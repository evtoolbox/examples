-------------------------------------------------------------------------------
--                                                                           --
-- Copyright 2019 EligoVision. Interactive Technologies                      --
--                                                                           --
-- Permission is hereby granted, free of charge, to any person obtaining a   --
-- copy of this software and associated documentation files                  --
-- (the "Software"), to deal in the Software without restriction, including  --
-- without limitation the rights to use, copy, modify, merge, publish,       --
-- distribute, sublicense, and/or sell copies of the Software, and to permit --
-- persons to whom the Software is furnished to do so, subject to the        --
-- following conditions:                                                     --
--                                                                           --
-- The above copyright notice and this permission notice shall be included   --
-- in all copies or substantial portions of the Software.                    --
--                                                                           --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS   --
-- OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF                --
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.    --
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY      --
-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,      --
-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE         --
-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                    --
--                                                                           --
-------------------------------------------------------------------------------

local scene = reactorController:getReactorByName("Scene")

local function inDegrees(angle)
	return angle * math.pi / 180.0
end

Pointer = class("Pointer")
	:field("mask", NodeReactor.Mask.CLICKABLE)

	:compositefield("laser")
		:field("geode")
		:field("geodePat")
		:field("defaultLength", 10.0)
		:field("defaultRadius", 0.0005)
		:field("color", osg.Vec4(255/255.0, 120/255.0, 0.0, 0.9))
	:done()
	:field("controllerModel")
	:field("avatar")
	:field("lineSegment")
	:field("root")
	:field("mouseHandler")
	-- NOTE: onIntersectionsCallback returns 2 arguments:
	--		1. osg.Intersection object to set laser length to corresponding
	--		2. boolean value to reset laser length to default if no appropriate intersection found
	:field("onIntersectionsCallback")
	:field("onButtonPressedCallback")
:done()

function Pointer:_construct(aControllerModel, aOnIntersectionsCallback)
	self.controllerModel = aControllerModel

	self:_createLaser()

	self.avatar = osg.PositionAttitudeTransform()
	self.avatar:addChild(self.laser.geodePat)
	if self.controllerModel then self.avatar:addChild(self.controllerModel) end

	-- self.root = osg.PositionAttitudeTransform()
	self.root = osg.MatrixTransform()
	self.root:addChild(self.avatar)

	self:_createMouseHandler()

	self.onIntersectionsCallback = aOnIntersectionsCallback
end

function Pointer:_createLaser()
	aCenter = aCenter or osg.Vec3(0.0, 0.0, -self.laser.defaultLength*0.5)
	aLength = aLength or self.laser.defaultLength
	aRadius = aRadius or self.laser.defaultRadius

	local material = osg.Material()
	material:setDiffuse(osg.Material.FRONT_AND_BACK, self.laser.color)
	material:setEmission(osg.Material.FRONT_AND_BACK, self.laser.color)

	local cylinder = osg.Cylinder(aCenter, aRadius, aLength)
	local drawable = osg.ShapeDrawable(cylinder)
	self.laser.geode = osg.Geode()
	self.laser.geode:addDrawable(drawable)
	self.laser.geode:getOrCreateStateSet():setAttributeAndModes(material, osg.StateAttribute.ON)

	self.laser.geodePat = osg.PositionAttitudeTransform()
	self.laser.geodePat:addChild(self.laser.geode)

	self.lineSegment = osg.LineSegment(osg.Vec3(0.0, 0.0, 0.0), osg.Vec3(0.0, 0.0, -aLength*1.05))		-- NOTE: -z direction
end

function Pointer:onButtonPressed()
	if self.onButtonPressedCallback then
		self.onButtonPressedCallback()
	end
end

function Pointer:setLaserLength(aLength)
	self.laser.geodePat:setScale(osg.Vec3(1.0, 1.0, aLength/self.laser.defaultLength))
end

function Pointer:setMatrix(aMatrix)
	self.root:setMatrix(aMatrix)
	self:calculateIntersection()
end

function Pointer:updatePositionAndAttitude(position, rotation)
	self.root:setMatrix(osg.Matrix.translate(position)*osg.Matrix.rotate(rotation))
	self:calculateIntersection()
end

function Pointer:show()
	self.root:setNodeMask(NodeReactor.Mask.VISIBLE)
end

function Pointer:hide()
	self.root:setNodeMask(0x0)
end

function Pointer:calculateIntersection()
	local ppl = self.root:getParentalNodePaths(scene.node)
	local local2world = osg.computeLocalToWorld(ppl:at(0))

	local segment = osg.LineSegment()
	segment:mult(self.lineSegment, local2world)

	local intersector = osgUtil.LineSegmentIntersector(osgUtil.Intersector.MODEL, segment:getStart(), segment:getEnd())
	local intersectionVisitor = osgUtil.IntersectionVisitor(intersector)
	intersectionVisitor:setTraversalMode(osg.NodeVisitor.TRAVERSE_ALL_CHILDREN)	-- NOTE: Enabling osg.Swithes
	intersectionVisitor:setUseKdTreeWhenAvailable(true)
	intersectionVisitor:setTraversalMask(self.mask)
	scene.node:accept(intersectionVisitor)

	if not intersector:containsIntersections() then
		--		loginfo("No intersections!")
		self:setLaserLength(self.laser.defaultLength)
	else
		local intersections = intersector:getIntersections()
		logdebug("Found intersections:", #intersections)

		if not self.onIntersectionsCallback then
			return
		end

		local intersection, updateLaserLength = self.onIntersectionsCallback(intersections)
		if intersection then
			local distanceToIntersectionPoint = (intersection:getWorldIntersectPoint() - segment:getStart()):length()
			self:setLaserLength(distanceToIntersectionPoint)
		elseif updateLaserLength then
			self:setLaserLength(self.laser.defaultLength)
		end
	end
end

local position = osg.Vec3()
local rotation = osg.Quat()
function Pointer:_createMouseHandler()
	self.mouseHandler = osgGA.GUIEventHandler(function(ea, aa)
		local pat = self.root:asPositionAttitudeTransform()

		if ea:getEventType() == osgGA.GUIEventAdapter.MOVE then
			if bit_and(ea:getModKeyMask(), osgGA.GUIEventAdapter.MODKEY_LEFT_CTRL) ~= 0 then
				local w = ea:getWindowWidth()
				local h = ea:getWindowHeight()
				local x = ea:getX()/w - 0.5
				local y = ea:getY()/h - 0.5

				rotation = euler2quat(osg.Vec3(y*math.pi, 0.0, -x*math.pi))
				self:updatePositionAndAttitude(position, rotation)
			end
		elseif ea:getEventType() == osgGA.GUIEventAdapter.KEYDOWN then
			local STEP = 0.02
			local key = ea:getKey()
			if key == bit_or(osgGA.GUIEventAdapter.KEY_Up) then
				position:z(position:z() + STEP)
			elseif key == bit_or(osgGA.GUIEventAdapter.KEY_Down) then
				position:z(position:z() - STEP)
			elseif key == bit_or(osgGA.GUIEventAdapter.KEY_Right) then
				position:x(position:x() + STEP)
			elseif key == bit_or(osgGA.GUIEventAdapter.KEY_Left) then
				position:x(position:x() - STEP)
			end
			self:updatePositionAndAttitude(position, rotation)
		end

		return false
	end)
end
