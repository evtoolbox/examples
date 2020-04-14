-- Example of Camera positioning.

-- Setting one of view matrices from viewMatrix table to change camera's
-- position every <period> seconds.
-- Camera's 'center' is coordinate system origin and 'up' is aligned with z axis.

-- Getting default main camera
local mainCamera = viewer:getCamera()

local distance	= 0.3	-- metres
local altitude	= 0.2	-- metres
local center	= osg.Vec3(0.0, 0.0, 0.0)
local up		= osg.Vec3(0.0, 0.0, 1.0)

local viewMatrix = {
	osg.Matrix.lookAt(osg.Vec3(0.0, distance, altitude), center, up),	-- Front
	osg.Matrix.lookAt(osg.Vec3(-distance, 0.0, altitude), center, up),	-- Left
	osg.Matrix.lookAt(osg.Vec3(0.0, -distance, altitude), center, up),	-- Back
	osg.Matrix.lookAt(osg.Vec3(distance, 0.0, altitude), center, up),	-- Rigth
}

local period		= 2.0	-- seconds
local currentMatrix	= 1

local timer = reactorController:getReactorByName("timer") -- must be presented in the project
timer:subscribeEvent("onAlarm", function()
	currentMatrix = currentMatrix % #viewMatrix + 1
	mainCamera:setViewMatrix(viewMatrix[currentMatrix])
end)

mainCamera:setViewMatrix(viewMatrix[currentMatrix])	-- initial positioning
timer:start(period, timer.Mode.LOOP)
