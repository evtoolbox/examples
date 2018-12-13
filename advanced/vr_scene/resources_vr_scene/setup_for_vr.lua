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

-- Simple scene in VR
-- We are in the center of 2x2 (metres) box

-- EV Toolbox 3.2.0-beta7
-- EV Toolbox 3.2.0-beta8 for statsHandler

local scene = reactorController:getReactorByName("Scene")


local cameraManipulator
local cameraEye		= osg.Vec3(0.0, 0.0, 0.0)
local cameraCenter	= osg.Vec3(0.0, 0.0001, 0.0)
local cameraUp		= osg.Vec3(0.0, 0.0, 1.0)

-- Create device and setup view config
local hmdDevice = EVosgHMD.Device.createBestDevice()

if hmdDevice then
	-- Apply Head Mounted Display (HMD) View config
	local viewConfigHMD = EVosgHMD.ViewConfigHMD(hmdDevice)
	viewer:apply(viewConfigHMD)

	if statsHandler then
		statsHandler:reset()	-- Must be reset after applying new view config
	end

	-- Create gyroscope manipulator
	cameraManipulator = hmdDevice:createCameraManipulator()

	scene:subscribeEvent("onScreenClick", function()
		cameraManipulator:home(0.0)
	end)
else
	-- Create trackball manipulator
	cameraManipulator = osgGA.OrbitManipulator()
	cameraManipulator:setMinimumDistance(0.0)
end


-- Setup manipulator
cameraManipulator:setHomePosition(cameraEye, cameraCenter, cameraUp, false)
viewer:setCameraManipulator(cameraManipulator)
cameraManipulator:home(0.0)


-- Graphics optimization

-- Turn off lighting for the whole scene
scene.node:getOrCreateStateSet():setMode(GLenum.GL_LIGHTING, osg.StateAttribute.OFF)


-- Change statistics level
if statsHandler then
	statsHandler:setLevel(1)
end
