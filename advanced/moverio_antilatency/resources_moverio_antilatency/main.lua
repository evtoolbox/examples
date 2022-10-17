local logger = set_lua_logger("stereo_on_moverio")


local pluginManager = evi.PluginManager.instance()
if pluginManager then
	local result = pluginManager:registerPlugin("moverio")
	if result < 0 then
		logger:error("'moverio' plugin not registered")
	else
		logger:info("'moverio' plugin registered")
	end
end


-- Setup stereo
-- NOTE: Fusion distance is important!

local ds = osg.DisplaySettings()
ds:setStereo(true)
ds:setEyeSeparation(0.063)
ds:setDisplayType(osg.DisplaySettings.HEAD_MOUNTED_DISPLAY)
ds:setStereoMode(osg.DisplaySettings.HORIZONTAL_SPLIT)

-- BT-40: 60" (1.524 metres) support (virtual viewing distance 2.5 m [8.2 feet])
local screenDiagonalDistanceRatio = 1.524/2.5

-- NOTE: Pixcell shift amount is zero (step = 32) for display distance = 4.6 metres
local screenDistance	= 4.6											-- metres
local screenDiagonal	= screenDiagonalDistanceRatio*screenDistance	-- metres
local screenAspect		= 16.0/9.0

local h		= screenDiagonal/math.sqrt(1.0 + screenAspect*screenAspect)
local w		= h*screenAspect
local fovy	= 2.0*(math.atan(0.5*h/screenDistance))*180.0/math.pi		-- in degrees

logger:info("Screen width = ", w, ", height = ", h, "; camera fovy = ", fovy)

ds:setScreenWidth(w)
ds:setScreenHeight(h)
ds:setScreenDistance(screenDistance)

-- NOTE: This is deprecated SceneView technique (use assignStereoOrKeystoneToCamera instead!):
-- viewer:getCamera():setProjectionMatrixAsPerspective(fovy, screenAspect, 0.1, 100.0)
-- viewer:setDisplaySettings(ds)

viewer:assignStereoOrKeystoneToCamera(viewer:getCamera(), ds)


local setupMOVERIO = function()
	-- NOTE: If there is no USB permission, first call can be failed
	if moverio.DisplayManager.displayMode() ~= moverio.DISPLAY_MODE_3D then
		local result = moverio.DisplayManager.setDisplayMode(moverio.DISPLAY_MODE_3D)
		logger:info("Set display to 3D result = ", result)
	else
		logger:info("Already in 3D mode")
	end
	local result = moverio.DisplayManager.setBrightnessMode(moverio.BRIGHTNESS_MODE_MANUAL)
	logger:info("Set brightness mode to manual result = ", result)
	local brightnessValue = 20	-- [0 .. 20]
	local result = moverio.DisplayManager.setBrightness(brightnessValue)
	logger:info("Set brightness to ", brightnessValue, " result = ", result)

	moverio.SensorManager.open(moverio.SENSOR_TYPE_ROTATION_VECTOR)

	-- NOTE: It's better to use SceneGraph's fusion distance
	--       against screenHorizontalShiftStep when you are in the stereo (3D mode)!
	logger:info("ScreenHorizontalShiftStep was ", moverio.DisplayManager.screenHorizontalShiftStep())
	moverio.DisplayManager.setScreenHorizontalShiftStep(32)	-- 32 is default value
end


--local rotationSensorData

if moverio then
	local systemReactor = reactorController:getReactorByName("System")
	systemReactor:subscribeEvent("onApplicationStart", setupMOVERIO)
	systemReactor:subscribeEvent("onApplicationResume", setupMOVERIO)
	systemReactor:subscribeEvent("onApplicationPause", function()
		local result = moverio.DisplayManager.setDisplayMode(moverio.DISPLAY_MODE_2D)
		logger:info("Set display to 2D result = ", result)
	end)

--	bus:subscribe(function()
--			rotationSensorData = moverio.SensorManager.grabData(moverio.SENSOR_TYPE_ROTATION_VECTOR, evi.getCurrentTimeNs())
--	end)
else
	logger:error("NO MOVERIO PLUGIN")
end

require "antilatency.lua"
