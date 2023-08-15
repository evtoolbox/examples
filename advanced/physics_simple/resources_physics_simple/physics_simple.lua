-------------------------------------------------------------------------------
--                                                                           --
-- Copyright 2020-2021 EligoVision. Interactive Technologies                 --
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

-- EV Toolbox 3.3.1 required

local logger = set_logger("ev_evi.lua.app.physics_simple")

local scene = reactorController:getReactorByName("Scene")
local sceneStateSet = scene.node:getOrCreateStateSet()

-- Optimizations
sceneStateSet:setMode(GLenum.GL_CULL_FACE, osg.StateAttribute.ON)
sceneStateSet:setMode(GLenum.GL_BLEND, osg.StateAttribute.OFF)

-- Helper functions
local function xyz_str(v)
	return string.format("[%.5f, %.5f, %.5f]", v:x(), v:y(), v:z())
end
local function xyzw_str(v)
	return string.format("[%.5f, %.5f, %.5f, %.5f]", v:x(), v:y(), v:z(), v:w())
end


-- LinearMath
local v1		= bt.Vector3(1.0, 0.0, 0.0)
local quat1		= bt.Quaternion(bt.Vector3(0.0, 0.0, 1.0), math.pi/2)
local matrix	= bt.Matrix3x3(quat1)

logger:info("v1 = "							, xyz_str(v1), "; quat1 = ", xyzw_str(quat1))
logger:info("2*v1 = "						, xyz_str(2*v1))
logger:info("v1*3 = "						, xyz_str(v1*3))
logger:info("bt.quatRotate(quat1, v1) = "	, xyz_str(bt.quatRotate(quat1, v1)))


-- Dynamics

-- create physics world
local collisionConfiguration = bt.DefaultCollisionConfiguration()
local dispatcher = bt.CollisionDispatcher(collisionConfiguration)
local pairCache = bt.AxisSweep3(bt.Vector3(-100.0, -100.0, -100.0), bt.Vector3(100.0, 100.0, 100.0))
local constraintSolver = bt.SequentialImpulseConstraintSolver()
local physicsWorld = bt.DiscreteDynamicsWorld(dispatcher, pairCache, constraintSolver, collisionConfiguration)

physicsWorld:setGravity(bt.Vector3(0.0, 0.0, -9.8))

-- create plane
local planeObject = bt.CollisionObject()
planeObject:setCollisionShape(bt.StaticPlaneShape(bt.Vector3(0.0, 0.0, 1.0), 0.0))
planeObject:setFriction(1.0)
physicsWorld:addCollisionObject(planeObject)


-- local optimizer = osgUtil.Optimizer()
local function createDrawable(shape)
	local drawable = osg.ShapeDrawable(shape)
	drawable:setColorArray(nil)
	drawable:setUseVertexBufferObjects(true)
	drawable:setUseVertexArrayObject(true)
	-- optimizer:optimize(drawable)

	return drawable
end


-- Box
local boxHalfSize = 0.05
local boxDrawable = createDrawable(osg.Box(osg.Vec3(0.0, 0.0, 0.0), 2*boxHalfSize))
local boxShape = bt.BoxShape(boxHalfSize*bt.Vector3(1.0, 1.0, 1.0))

-- Sphere
local sphereRadius = 0.05
local sphereDrawable = createDrawable(osg.Sphere(osg.Vec3(0.0, 0.0, 0.0), sphereRadius))
local sphereShape = bt.SphereShape(sphereRadius)

-- Cylinder
local cylinderRadius, cylinderHeight = 0.05, 0.025
local cylinderDrawable = createDrawable(osg.Cylinder(osg.Vec3(0.0, 0.0, 0.0), cylinderRadius, cylinderHeight))
local cylinderShape = bt.CylinderShapeZ(bt.Vector3(cylinderRadius, cylinderRadius, cylinderHeight/2))

-- Capsule
local capsuleRadius, capsuleHeight = 0.025, 0.1
local capsuleDrawable = createDrawable(osg.Capsule(osg.Vec3(0.0, 0.0, 0.0), capsuleRadius, capsuleHeight))
local capsuleShape = bt.CapsuleShapeZ(capsuleRadius, capsuleHeight)


-- Sync graphics function
local rigidBodyTransform = bt.Transform.getIdentity()
local function syncDrawableTransform(motionState, drawableTransform)
	motionState:getWorldTransform(rigidBodyTransform)
	drawableTransform:setMatrix(bt.bt2osg(rigidBodyTransform))
end


local function addRigidBody(drawable, shape)
	local rbTransform = bt.Transform.getIdentity()
	local x, y = 1 - math.random(0, 200)/100.0, 1 - math.random(0, 200)/100.0
	rbTransform:setOrigin(bt.Vector3(x, y, 1.0))
	rbTransform:setRotation(bt.Quaternion(bt.Vector3(0.0, 1.0, 0.0), math.random(0, 100)/100.0*math.pi))
	local motionState1 = bt.DefaultMotionState(rbTransform)
	local rb = bt.RigidBody(0.1, motionState1, shape, bt.Vector3(0.0015, 0.0015, 0.0015))
	rb:setAngularFactor(1.0)
	rb:setDamping(0.075, 0.075)
	rb:setFriction(0.95)

	-- Some tuning:
	if shape == sphereShape then
		rb:setRollingFriction(0.01)
		rb:setSpinningFriction(0.5)
	elseif shape == cylinderShape or shape == capsuleShape then
		rb:setRollingFriction(0.0015)
		rb:setSpinningFriction(0.0015)
	end

	physicsWorld:addRigidBody(rb)

	-- Graphics
	local drawableTransform = osg.MatrixTransform()
	local r, g, b = math.random(0, 100)/100.0, math.random(0, 100)/100.0, math.random(0, 100)/100.0
	drawableTransform:getOrCreateStateSet():addUniform(osg.Uniform.Vec4f("ev_MaterialDiffuse", osg.Vec4(r, g, b, 1.0)))

	drawableTransform:addChild(drawable)
	scene.node:addChild(drawableTransform)

	syncDrawableTransform(motionState1, drawableTransform)
	-- NOTE: Do not specify parameters (in callback function) if you don't need it.
	--       Performance will be better and garbagecollector will be happy [for EV Toolbox 3.4.7 and newer].
	local nc = osg.NodeCallback(function(--[[node, nodeVisitor]])
		if rb:isActive() then
			syncDrawableTransform(motionState1, drawableTransform)
		else
			bus:subscribeOnce(function()
				physicsWorld:removeCollisionObject(rb)
				drawableTransform:setUpdateCallback(nil)		-- Importrant for GC

				scene.node:removeChild(drawableTransform)
			end)
		end
		return true
	end)
	drawableTransform:setUpdateCallback(nc)
end

addRigidBody(boxDrawable, boxShape)

local frame = 0
local lastSimulationTime
bus:subscribe(function()
	local time = timer:getTime()
	physicsWorld:stepSimulation((time - (lastSimulationTime or time)))
	lastSimulationTime = time

	frame = frame + 1
	if physicsWorld:getNumCollisionObjects() <= 100 then
		if frame % 10 == 0 then
			addRigidBody(boxDrawable, boxShape)
--			addRigidBody(sphereDrawable, sphereShape)		-- too many draw calls (shape not optimized)
--			addRigidBody(cylinderDrawable, cylinderShape)	-- too many draw calls (shape not optimized)
--			addRigidBody(capsuleDrawable, capsuleShape)		-- too many draw calls (shape not optimized)
		end
	end
end)


-- RTT Stats Handler
if statsHandler then
	viewer:removeEventHandler(statsHandler)
else
	statsHandler = EVosgViewer.StatsHandler(viewer)
end


local graphics = require("base/util/graphics.lua")
local stw, sth = 1024, 1024
local scale = 0.25 -- 25cm
local defaultAspect = 1920.0/1080.0
local statsTexture = graphics.createTexture2D(stw, sth)
local statsQuad = osg.createTexturedQuad(osg.Vec3(-0.5*defaultAspect*scale, 0.0, 0.0),
										 osg.Vec3(1.0*defaultAspect*scale, 0.0, 0.0),
										 osg.Vec3(0.0, scale, 0.0))
local statsQuadSS = statsQuad:getOrCreateStateSet()
statsQuadSS:setTextureAttribute(0, statsTexture)
statsQuadSS:setMode(GLenum.GL_DEPTH_TEST, osg.StateAttribute.OFF)
statsQuadSS:setMode(GLenum.GL_CULL_FACE, osg.StateAttribute.OFF)
statsQuadSS:setMode(GLenum.GL_LIGHTING, osg.StateAttribute.OFF)
statsQuadSS:setMode(GLenum.GL_BLEND, osg.StateAttribute.ON)
statsQuadSS:setDefine("EV_GL_OPACITY_FROM_DIFFUSE", osg.StateAttribute.ON)
statsQuadSS:setRenderBinDetails(10, "RenderBin", osg.StateSet.USE_RENDERBIN_DETAILS)

local statsParentReactor = reactorController:getReactorByName("VRController") or scene
statsParentReactor.node:addChild(statsQuad)

local statsCamera = statsHandler:getCamera()
statsCamera:setRenderOrder(osg.Camera.PRE_RENDER, 5)
statsCamera:setRenderTargetImplementation(osg.Camera.FRAME_BUFFER_OBJECT)
statsCamera:attach(osg.Camera.COLOR_BUFFER0, statsTexture, 0, 0, false, 0, 0)
statsCamera:setClearColor(osg.Vec4(0.0, 0.0, 0.0, 0.75))

bus:subscribeOnce(function()
	statsCamera:setClearMask(bit_or(GLenum.GL_COLOR_BUFFER_BIT, GLenum.GL_DEPTH_BUFFER_BIT))
	statsCamera:setProjectionMatrix(osg.Matrix.ortho2D(0, 1920, 0, 1080))
	statsCamera:setViewport(0, 0, stw, sth);
	statsHandler:setLevel(4)
end)
