local logger = set_lua_logger("test")

-- sample creation and config
local audioResource = resourceRepository:getResourceByName("fanfare.mp3", ResourceKind.AUDIO)
audioSample = resourceRepository:loadResource(audioResource, "audioSource", true)
audioSample:setLooping(true)

-- audio system instance
audioSystem = EVosgAV.AudioSystem.instance()

-- creating audio node
audioNode = EVosgAV.AudioNode(audioSample)
audioNode:setDataVariance(osg.Object.DYNAMIC) -- dynamic initial

-- creating listener
local listenerCb = EVosgAV.AudioListenerCallback()
local camera = viewer:getCamera()
camera:addUpdateCallback(listenerCb) -- listener tracking camera

-- creating transforms for our models
local sTrans = osg.MatrixTransform()

-- adding transforms to scene reactor
scene = reactorController:getReactorByName("Scene")
scene.node:addChild(sTrans)

-- adding models and audio node to transform
local pin = reactorController:getReactorByName("Pin")
sTrans:addChild(pin.node)
sTrans:addChild(audioNode)

-- consts
local radius = 0.1;

-- animation(rotation around center)
function rotateModel(transform, period)
	local startTime = viewer:getFrameStamp():getSimulationTime()
	local flag = false
	local path = 0

	transform:setUpdateCallback(osg.NodeCallback(function()
		local time = viewer:getFrameStamp():getSimulationTime()
		local dt = time - startTime + path
		if audioNode:getDataVariance() ~= osg.Object.DYNAMIC then
			startTime = time
			path = not flag and dt or path
			flag = true

			return true
		end

		flag = false

		local percent = dt/period
		local angle = percent*2*math.pi

		transform:setMatrix(osg.Matrix.translate(osg.Vec3(radius*math.cos(angle), radius*math.sin(angle), 0.0)))

		return true
	end))
end

-- play sound and animation
audioHandle = audioNode:play()
rotateModel(sTrans, 30)
audioSystem:set3dSourceMinMaxDistance(audioHandle, 0.05, 0.5) -- attenuation min/max distance settings
audioSystem:setVolume(audioHandle, 1.0)

-- interface logic(buttons, switches)
local attenuationModels = {
	{name="No\nAttenuation", model=EVosgAV.AudioSource.NO_ATTENUATION},
	{name="Inverse\nDistance", model=EVosgAV.AudioSource.INVERSE_DISTANCE},
	{name="Linear\nDistance", model=EVosgAV.AudioSource.LINEAR_DISTANCE},
	{name="Exponential\nDistance", model=EVosgAV.AudioSource.EXPONENTIAL_DISTANCE},
}

local attenuationModelIdx = 3 -- default is linear distance attenuation

local stopBtn = reactorController:getReactorByName("btn/stop")
stopBtn:subscribeEvent("onDown", function()
	if not audioSystem:isValidVoiceHandle(audioHandle) then
		logger:warn("Can't stop audio node, already stopped!")
	end
	audioSystem:stop(audioHandle)
end)

local resumeBtn = reactorController:getReactorByName("btn/resume")
resumeBtn:subscribeEvent("onDown", function()
	if not audioSystem:isValidVoiceHandle(audioHandle) then
		logger:warn("Can't resume audio node, it is stopped!");
		return
	end

	if not audioSystem:getPause(audioHandle) then
		logger:warn("Can't resume audio node, already playing!");
		return
	end

	audioSystem:setPause(audioHandle, false)
	audioNode:dirty()
end)

local playBtn = reactorController:getReactorByName("btn/play")
playBtn:subscribeEvent("onDown", function()
	audioHandle = audioNode:play()
end)

local pauseBtn = reactorController:getReactorByName("btn/pause")
pauseBtn:subscribeEvent("onDown", function()
	if not audioSystem:isValidVoiceHandle(audioHandle) then
		logger:warn("Can't pause audio node, already stopped!");
		return
	end

	if audioSystem:getPause(audioHandle) then
		logger:warn("Can't pause, audio node is not playing...");
		return;
	end

	audioSystem:setPause(audioHandle, true)
end)

local attenuationBtn = reactorController:getReactorByName("btn/attenuation")
attenuationBtn:subscribeEvent("onDown", function()
	attenuationModelIdx = attenuationModelIdx + 1
	if attenuationModelIdx > #attenuationModels then attenuationModelIdx = 1 end
	local attenuationModel = attenuationModels[attenuationModelIdx]
	reactorController:getReactorByName("text/attenuation").text.value = "Attenuation:\n" .. attenuationModel.name
	audioSystem:set3dSourceAttenuation(audioHandle, attenuationModel.model, 1.75) -- 1.75 is roloff factor
end)

local sourceBtn = reactorController:getReactorByName("btn/source")
local sourceText = reactorController:getReactorByName("text/source")
sourceBtn:subscribeEvent("onDown", function()
	if audioNode:getDataVariance() == osg.Object.DYNAMIC then
		audioNode:setDataVariance(osg.Object.STATIC)
		sourceText.text.value = "AudioSource:\nStatic"
	else
		audioNode:setDataVariance(osg.Object.DYNAMIC)
		audioNode:dirty()
		sourceText.text.value = "AudioSource:\nDynamic"
	end
end)



