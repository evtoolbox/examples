-------------------------------------------------------------------------------
--                                                                           --
-- Copyright 2024 EligoVision. Interactive Technologies                      --
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

-- EV Toolbox 3.5.0 required
-- Docs: https://eligovision.ru/toolbox/docs/3.5/API/interfaces/evar2/pkg_evar2.html

local logger = set_lua_logger("detector_roi")

local width, height = 0.26, 0.3

local pixelThreshold, threshold = 30, 0.3	-- Default is 30 [0, 255] and 0.2 (20%)

local marker_l = evar.MarkerROI(1, evar.Rectd(0.0, 0.0, width, height))
local marker_c = evar.MarkerROI(2, evar.Rectd(0.37, 0.0, width, height), pixelThreshold, threshold)
local marker_r = evar.MarkerROI(3, evar.Rectd(0.74, 0.0, width, height))

trackingSystem:initROIPipeline()
trackingSystem.roiClassifier:addMarker(marker_l)
trackingSystem.roiClassifier:addMarker(marker_c)
trackingSystem.roiClassifier:addMarker(marker_r)


local function changeColor(rect_reactor, marker)
	local c = marker:isActive() and osg.Vec4(0.0, 0.5, 0.0, marker:value()) or osg.Vec4(0.5, 0.0, 0.0, marker:threshold())
	rect_reactor.rect.color = c
end

local btn_l = reactorController:getReactorByName("btn_left")
local btn_c = reactorController:getReactorByName("btn_centre")
local btn_r = reactorController:getReactorByName("btn_right")

bus:subscribe(function()
	changeColor(btn_l, marker_l)
	changeColor(btn_c, marker_c)
	changeColor(btn_r, marker_r)
end)

local btn_new_ref = reactorController:getReactorByName("btn_new_ref")
btn_new_ref:subscribeEvent("onClick", function()
	trackingSystem.roiDetector:requestNewReferenceFrame()
end)
