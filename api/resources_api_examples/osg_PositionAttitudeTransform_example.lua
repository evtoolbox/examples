-- Example of object positioning using osg.PositionAttitudeTransform.

-- On startup model is in the Scene. We move it to initial position and insert osg.PositionAttitudeTransform between them in the Scene Graph hierarchy to transform model with it step by step (compare with 'osg_MatrixTransform_example' example).

local scene	= reactorController:getReactorByName("Scene") -- must be presented in the project
local timer	= reactorController:getReactorByName("timer") -- must be presented in the project
local model	= reactorController:getReactorByName("logo_model") -- must be presented in the project
local pat	= osg.PositionAttitudeTransform()

-- initial object transformation using high-level api
model.trans		= osg.Vec3(0.0, 0.0, -0.3)
model.rotate	= osg.Vec3(0.0, 0.0, 0.0)

scene:freeze()	-- lock the object to change high-level objects hierarchy
scene:removeChild(model)
scene:thaw()

-- NOTE: we do not need any freeze/thaw here to change OSG nodes' hierarchy
scene.node:addChild(pat)
pat:addChild(model.node)

local period	= 2.0 --seconds
local step		= 0

timer:subscribeEvent("onAlarm", function()
	step = step % 3 + 1

	if step == 1 then
		loginfo("Rotate 45 degrees on the 0z axis")
		pat:setAttitude(osg.Quat(math.rad(45.0), osg.Vec3(0.0, 0.0, 1.0)))
	elseif step == 2 then
		loginfo("Move along 0x axis by -0.05 metres")
		pat:setPosition(osg.Vec3(-0.05, 0.0, 0.0))
	elseif step == 3 then
		loginfo("Increase the scale by 2 times along 0y axis")
		pat:setScale(osg.Vec3(1.0, 2.0, 1.0))

		-- All transformation completed, stop timer
		timer:stop()
	end
end)

timer:start(period, timer.Mode.LOOP)

return pat
