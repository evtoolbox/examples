-- Example of object positioning using osg.PositionAttitudeTransform.

-- On startup model is in the Scene. We move it to initial position and insert osg.MatrixTransform between them in the Scene Graph hierarchy to change model's position, scale and rotation by one step (compare with 'osg_PositionAttitudeTransform_example' example).

local scene	= reactorController:getReactorByName("Scene") -- must be presented in the project
local timer	= reactorController:getReactorByName("timer") -- must be presented in the project
local model	= reactorController:getReactorByName("logo_model") -- must be presented in the project
local mt	= osg.MatrixTransform()

-- initial object transformation using high-level api
model.trans		= osg.Vec3(0.0, 0.0, -0.3)
model.rotate	= osg.Vec3(0.0, 0.0, 0.0)

scene:freeze()	-- lock the object to change high-level objects hierarchy
scene:removeChild(model)
scene:thaw()

-- NOTE: we do not need any freeze/thaw here to change OSG nodes' hierarchy
scene.node:addChild(mt)
mt:addChild(model.node)

local period	= 2.0 --seconds
local step		= 0

-- Rotate 45 degrees on the 0z axis
local scaleMatrix = osg.Matrix.scale(osg.Vec3(1.0, 2.0, 1.0))
-- Move along 0x axis by -0.05 metres
local rotationMatrix = osg.Matrix.rotate(osg.Quat(math.rad(45.0), osg.Vec3(0.0, 0.0, 1.0)))
-- Increase the scale by 2 times along 0y axis
local translationMatrix = osg.Matrix.translate(osg.Vec3(-0.05, 0.0, 0.0))

local noTransformation	= osg.Matrix()
local transformation	= scaleMatrix
						* rotationMatrix
						* translationMatrix

						timer:subscribeEvent("onAlarm", function()
	step = step % 2 + 1

	mt:setMatrix(step == 1 and transformation or noTransformation)
end)

timer:start(period, timer.Mode.LOOP)
