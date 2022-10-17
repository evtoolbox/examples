local logger = set_lua_logger("antilatency_example")

-- EV.Logger.setCatPriority("ev_evi.evi_plugins", "DEBUG")

-- plugin initialization

local pluginManager = evi.PluginManager.instance()
if pluginManager then
	local result = pluginManager:registerPlugin("antilatency")
	if result < 0 then
		logger:error("'antilatency' plugin not registered")
	else
		logger:info("'antilatency' plugin registered")
	end
end

-- helpers

local function stage2string(stage)
	if stage == Antilatency.Alt.Tracking.Stage.InertialDataInitialization then
		return "InertialDataInitialization"
	elseif stage == Antilatency.Alt.Tracking.Stage.Tracking3Dof then
		return "Tracking3Dof"
	elseif stage == Antilatency.Alt.Tracking.Stage.Tracking6Dof then
		return "Tracking6Dof"
	elseif stage == Antilatency.Alt.Tracking.Stage.TrackingBlind6Dof then
		return "TrackingBlind6Dof"
	end
end

-- antilatency sample in lua

local deviceNetworkLibrary			= Antilatency.DeviceNetwork.ILibrary("libAntilatencyDeviceNetwork.so")
local altTrackingLibrary			= Antilatency.Alt.Tracking.ILibrary("libAntilatencyAltTracking.so")
local altEnvironmentSelectorLibrary	= Antilatency.Alt.Environment.Selector.ILibrary("libAntilatencyAltEnvironmentSelector.so")
local storageClientLibrary			= Antilatency.StorageClient.ILibrary("libAntilatencyStorageClient.so")

logger:info("Antilatency Device Network library ver. ", deviceNetworkLibrary:getVersion())

local deviceFilter = deviceNetworkLibrary:createFilter()
deviceFilter:addUsbDevice(Antilatency.DeviceNetwork.Constants.AllUsbDevices())
deviceFilter:addIpDevice(Antilatency.DeviceNetwork.Constants.AllIpDevicesIp(), Antilatency.DeviceNetwork.Constants.AllIpDevicesMask())
local network = deviceNetworkLibrary:createNetwork(deviceFilter)


-- Get environment serialized data from Antilatency Service.
-- Using "default" as key will return environment that marked as default in Antilatency Service.
local localStorage = storageClientLibrary:getLocalStorage()
local environmentCode = localStorage:read("environment", "default")

-- Get environment name from Antilatency Service
local environmentName = localStorage:read("environment", ".default")

-- Create environment object from the serialized data.
local altEnvironment = altEnvironmentSelectorLibrary:createEnvironment(environmentCode)

-- Get placement serialized data from Antilatency Service.
-- Using "default" as key will return placement that marked as default in Antilatency Service.
local placementCode = localStorage:read("placement", "default")

-- Create placement from the serialized data.
local placement = altTrackingLibrary:createPlacement(placementCode);

local extrapolationTime		= 0.06
local prevUpdateId			= nil
local altTrackingCotask		= nil

local trackingInfoReactor = reactorController:getReactorByName("tracking_info")
local cameraMatrix = osg.Matrix.identity()


local doTrackingStep = function()
	if altTrackingCotask and altTrackingCotask:isTaskFinished() then
		altTrackingCotask = nil
	end

	if not altTrackingCotask then
		-- Check if the network has been changed.
		local currentUpdateId = network:getUpdateId()
		if prevUpdateId ~= currentUpdateId then
			prevUpdateId = currentUpdateId
			logger:info("Antilatency Device Network update id has been incremented: ", currentUpdateId)
			logger:info("Searching for idle nodes that supports tracking task...")

			-- Create alt tracking cotask constructor to find tracking-supported nodes and start tracking task on node.
			local cotaskConstructor = altTrackingLibrary:createTrackingCotaskConstructor()

			local availableTrackingNodes = cotaskConstructor:findSupportedNodes(network)
			logger:info("Found ", availableTrackingNodes:size(), " tracking nodes")

			-- Get first idle node that supports tracking task.
			for i = 0, availableTrackingNodes:size() - 1 do
				local node = availableTrackingNodes:at(i)
				if network:nodeGetStatus(node) == Antilatency.DeviceNetwork.NodeStatus.Idle then
					logger:info("Tracking node found, node: ", node)	-- TODO: better log
					altTrackingCotask = cotaskConstructor:startTask(network, node, altEnvironment)
					break
				end
			end

			if not altTrackingCotask then
				logger:warn("Tracking node not found")
			end
		end
	end

	if altTrackingCotask then
		local extrapolatedState = altTrackingCotask:getExtrapolatedState(placement, extrapolationTime)

		local pose		= extrapolatedState:pose()
		local t			= pose:position()
		local r			= pose:rotation()

		local stability	= extrapolatedState:stability()
		local v			= extrapolatedState:velocity()
		local lav		= extrapolatedState:localAngularVelocity()

--		logger:info("pose: position = (", t:x(), ", ", t:y(), ", ", t:z(), "); rotation = (", r:x(), ", ", r:y(), ", ", r:z(), ", ", r:w(), ")")
		logger:info("stability: stage = ", stage2string(stability:stage()), ", value = ", stability:value())
--		logger:info("velocity = (", v:x(), ", ", v:y(), ", ", v:z(), ")")
--		logger:info("local angular velocity = (", lav:x(), ", ", lav:y(), ", ", lav:z(), ")")

		if trackingInfoReactor then
			trackingInfoReactor.text.value =
					"pose:\n  position =\n" ..	t:x() .. "\n    " .. t:y() .. "\n    ".. t:z() .. "\n"
				..	"  rotation =\n    " .. r:x() .. "\n    " .. r:y() .. "\n    " .. r:z() .. "\n    " .. r:w() .. "\n\n"
				..	"stability:\n  stage = " .. stage2string(stability:stage()) .. "\n  value = " .. stability:value() .. "\n"
		end

		cameraMatrix = osg.Matrix.rotate(osg.Quat(-r:x(), -r:y(), r:z(), r:w())*
										 osg.Quat(math.pi, osg.Vec3(1.0, 0.0, 0.0)))*
										 osg.Matrix.translate(osg.Vec3(t:x(), -t:y(), t:z())) --working solution

	end
end

bus:subscribe(doTrackingStep)


function createCameraManipulatorAntilatency()
	local result = osgGA.LuaCameraManipulator()

	result:setGetInverseMatrixCb(function()
		return osg.Matrix.inverse(cameraMatrix)
	end)

	return result
end

viewer:setCameraManipulator(createCameraManipulatorAntilatency())
