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

-- EV Toolbox 3.2.0-rc3
-- wvr, hmdDevice globals must be defined

local function setupViewMatrices()
	local leftViewMat	= osg.Matrix.inverse(wvr2osg_mat(wvr.GetTransformFromEyeToHead(wvr.WVR_Eye_Left, wvr.WVR_NumDoF_6DoF)))
	local rightViewMat	= osg.Matrix.inverse(wvr2osg_mat(wvr.GetTransformFromEyeToHead(wvr.WVR_Eye_Right, wvr.WVR_NumDoF_6DoF)))
	hmdDevice:setLeftEyeModelViewMatrix(leftViewMat)
	hmdDevice:setRightEyeModelViewMatrix(rightViewMat)

	loginfo("Left view matrix:")
	log_osg_mat(hmdDevice:traits():leftEyeModelViewMatrix())
	loginfo("Right view matrix:")
	log_osg_mat(hmdDevice:traits():rightEyeModelViewMatrix())
end

local function setupProjectionMatrices()
	-- Screen size = 0.118 0.0660001

	local leftProjMat	= wvr2osg_mat(wvr.GetProjection(wvr.WVR_Eye_Left, 0.1, 10))
	local rightProjMat	= wvr2osg_mat(wvr.GetProjection(wvr.WVR_Eye_Right, 0.1, 10))
	hmdDevice:setLeftEyeProjectionMatrix(leftProjMat)
	hmdDevice:setRightEyeProjectionMatrix(rightProjMat)

	loginfo("Left projection matrix:")
	log_osg_mat(hmdDevice:traits():leftEyeProjectionMatrix())
	loginfo("Right projection matrix:")
	log_osg_mat(hmdDevice:traits():rightEyeProjectionMatrix())
end

--[[
hmdDevice = EVosgHMD.DeviceManual()
setupViewMatrices()
setupProjectionMatrices()
--]]


local traits = wvr_deviceTraits()
hmdDevice = EVosgHMD.DeviceManual(traits)
local viewConfigHMD = EVosgHMD.ViewConfigHMD(hmdDevice)
viewer:apply(viewConfigHMD)

--setupViewMatrices()
--setupProjectionMatrices()

--local leftViewMat	= osg.Matrix.inverse(wvr2osg_mat(wvr.GetTransformFromEyeToHead(wvr.WVR_Eye_Left, wvr.WVR_NumDoF_6DoF)))
--local leftProjMat	= wvr2osg_mat(wvr.GetProjection(wvr.WVR_Eye_Left, 0.1, 10))
--setupTraits(hmdDevice, leftViewMat, leftProjMat)

--hmdDevice:setDistortionCoeffs(osg.Vec4(0.0, 0.0, 0.0, 0.0))

local wvrEvent = wvr.Event()
bus:subscribe(function()
	while wvr.PollEventQueue(wvrEvent) do
		logdebug("Event from WVR...")

		if wvrEvent:common():type() == wvr.WVR_EventType_IpdChanged then
			loginfo("WVR_EventType_IpdChanged")
			-- TODO: calculate ipd
--			setupViewMatrices()
		end

	end

	-- Head Mounted Display
	-- option 1
	local predictedMilliSec = 15.0

	local hmdPoseState = wvr.PoseState()
	wvr.GetPoseState(wvr.WVR_DeviceType_HMD, wvr.WVR_PoseOriginModel_OriginOnHead, predictedMilliSec, hmdPoseState)

	local hmdMat = wvr2osg_mat(hmdPoseState:poseMatrix())
	if hmdPoseState:isValidPose() then
		local mat = osg.Matrix.inverse(hmdMat)
		viewer:getCamera():setViewMatrix(mat)
	end

	-- Right controller
	local controllerPoseState = wvr.PoseState()
	wvr.GetPoseState(wvr.WVR_DeviceType_Controller_Right, wvr.WVR_PoseOriginModel_OriginOnHead, predictedMilliSec, controllerPoseState)

	if controllerPoseState:isValidPose() then
		local mat = wvr2osg_mat(controllerPoseState:poseMatrix())
		focusController:show()
		focusController:setMatrix(mat*osg.Matrix.translate(
				hmdMat:getItem(3, 0) + 0.25,
				hmdMat:getItem(3, 1) - 0.4,
				hmdMat:getItem(3, 2) - 0.2))
	else
		focusController:hide()
	end
end)
