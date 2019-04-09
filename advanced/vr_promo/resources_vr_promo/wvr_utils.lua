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

function wvr2osg_mat(m, disableTranspose)
--	loginfo(string.format("mat2 =\n(%f, %f, %f, %f)\n(%f, %f, %f, %f)\n(%f, %f, %f, %f)\n(%f, %f, %f, %f)\n",
--		m:get(0, 0), m:get(0, 1), m:get(0, 2), m:get(0, 3),
--		m:get(1, 0), m:get(1, 1), m:get(1, 2), m:get(1, 3),
--		m:get(2, 0), m:get(2, 1), m:get(2, 2), m:get(2, 3),
--		m:get(3, 0), m:get(3, 1), m:get(3, 2), m:get(3, 3)))

	if disableTranspose == true then
		return osg.Matrix(
			m:get(0, 0), m:get(0, 1), m:get(0, 2), m:get(0, 3),
			m:get(1, 0), m:get(1, 1), m:get(1, 2), m:get(1, 3),
			m:get(2, 0), m:get(2, 1), m:get(2, 2), m:get(2, 3),
			m:get(3, 0), m:get(3, 1), m:get(3, 2), m:get(3, 3))
	end

	return osg.Matrix(
		m:get(0, 0), m:get(1, 0), m:get(2, 0), m:get(3, 0),
		m:get(0, 1), m:get(1, 1), m:get(2, 1), m:get(3, 1),
		m:get(0, 2), m:get(1, 2), m:get(2, 2), m:get(3, 2),
		m:get(0, 3), m:get(1, 3), m:get(2, 3), m:get(3, 3))
end

function log_osg_mat(m)
	for i = 0, 3 do
		loginfo(string.format("%5g\t\t\t%5g\t\t\t%5g\t\t\t%5g",
							  m:getItem(i, 0), m:getItem(i, 1), m:getItem(i, 2), m:getItem(i, 3)))
	end
end

function wvr_deviceTraits()
	local traits = EVosgHMD.DeviceTraits()

	-- HTC Vive Focus screen size = 0.118 0.0660001

	local viewportSize = osg.Vec2(0.118/2, 0.118/2)	-- osg.Vec2(1440, 1440);

	local leftEyeModelViewMatrix	= osg.Matrix.inverse(wvr2osg_mat(wvr.GetTransformFromEyeToHead(wvr.WVR_Eye_Left, wvr.WVR_NumDoF_6DoF)))
	local leftEyeProjectionMatrix	= wvr2osg_mat(wvr.GetProjection(wvr.WVR_Eye_Left, 0.1, 10))

	local aspect = viewportSize:x()/viewportSize:y()

	-- Calculation others values
	local ipd					= leftEyeModelViewMatrix:getTrans():x()*2.0
	local trayToLensDistance	= viewportSize:y()*0.5
	local fov					= (math.pi*0.5 - math.atan(leftEyeProjectionMatrix:getItem(0, 0)*aspect))*2.0
	local screenToLensDistance	= viewportSize:y()*0.5/math.tan(fov*0.5)

	local xOffset = leftEyeProjectionMatrix:getItem(2, 0)
	local yOffset = -leftEyeProjectionMatrix:getItem(2, 1)
	local rightLensCenter = osg.Vec2((xOffset + 1.0)*viewportSize:x()*0.5, (yOffset + 1.0)*viewportSize:y()*0.5)
	local interLensDistance = rightLensCenter:x()*2.0	-- TODO: Try ipd
	local leftLensCenter = osg.Vec2(viewportSize:x() - interLensDistance*0.5, (yOffset + 1.0)*viewportSize:y()*0.5)

	loginfo("Traits calculated from model-view and projection matrices")
	loginfo("aspect", aspect)
	loginfo("fov", fov)
	loginfo("trayToLensDistance", trayToLensDistance)
	loginfo("screenToLensDistance", screenToLensDistance)
	loginfo("interLensDistance", interLensDistance)
	loginfo("ipd", ipd)

	traits:setDistortionModel(EVosgHMD.DeviceTraits.DistortionModel.BROWN)	-- PANOTOOLS
	traits:setViewportSize(viewportSize)
	traits:setFov(fov)
	traits:setTrayToLensDistance(trayToLensDistance)
	traits:setScreenToLensDistance(screenToLensDistance)
	traits:setInterLensDistance(interLensDistance)
	traits:setIpd(ipd)
	traits:setWarpScale(0.03)	-- for PANOTOOLS model only

	-- calibrated by hand
	traits:setDistortionCoeffs(osg.Vec4(0.42, 2.46, 0.0, 1.0))
	traits:setInterLensDistance(0.046)

	return traits
end
