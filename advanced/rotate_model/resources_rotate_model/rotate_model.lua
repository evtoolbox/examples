-------------------------------------------------------------------------------
--                                                                           --
-- Copyright 2018 EligoVision. Interactive Technologies                      --
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

local logoModel = reactorController:getReactorByName("logo")
local touchZone = reactorController:getReactorByName("touch_zone")

local rotateModeEnabled		= false
local rotationAxis			= osg.Vec3(0.0, 0.0, 1.0) -- constant
local clickPoint			= nil -- { x = 0, y = 0}
local initialMatrix			= nil -- osg.Quat()


touchZone:subscribeEvent("onDown", function()
	loginfo("Rotation began!")
	rotateModeEnabled = true
	initialMatrix = logoModel:getMatrix()
end)


local eventsHandler = osgGA.GUIEventHandler(function(ea, aa)
	if ea:getEventType() == osgGA.GUIEventAdapter.RELEASE then
		if rotateModeEnabled then loginfo("Rotation done!") end

		rotateModeEnabled = false
		clickPoint = nil
	elseif ea:getEventType() == osgGA.GUIEventAdapter.DRAG and rotateModeEnabled then
		local radiansPerPixel = 2.0 * math.pi / ea:getWindowWidth()
		if not clickPoint then clickPoint = { x = ea:getX(), y = ea:getY() } end

		local rotationMatrix = osg.Matrix.rotate(osg.Quat((ea:getX() - clickPoint.x)*radiansPerPixel, rotationAxis))
		logoModel:setMatrix(initialMatrix * rotationMatrix)
	end

	return false
end)
viewer:addEventHandler(eventsHandler)
