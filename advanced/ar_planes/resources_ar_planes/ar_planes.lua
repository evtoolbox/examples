-------------------------------------------------------------------------------
--                                                                           --
-- Copyright 2023 EligoVision. Interactive Technologies                      --
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

-- EV Toolbox 3.4.11 required
-- Docs: https://eligovision.ru/toolbox/docs/3.4/API/interfaces/evar2/pkg_evar2.html

local logger = set_lua_logger("planes_ar")

-- Helper function
function getReactorOrDie(name)
	local reactor = reactorController:getReactorByName(name)
	if not reactor then
		error("Cannot find reactor '" .. tostring(name) .. "'")
	end
	return reactor
end

local sys = evi.os()

local info_txt				= getReactorOrDie("info_txt")
local button				= getReactorOrDie("btn")
local ar_plane_transform	= getReactorOrDie("ar_plane_transform")
local plane_image			= getReactorOrDie("plane/image")
local plane_model			= getReactorOrDie("plane/model")

-- initial state
button:hide(0x0)			-- not visible, not clickable
ar_plane_transform:hide()	-- just hide (does not matter if clickable or not)
plane_image:show()			-- just show (does not matter if clickable or not)
plane_model:hide()

-- NOTE: trackingSystem is global (used by TrackingSystemReactor also)
local busARCore	= trackingSystem.busARCore
local busARKit	= trackingSystem.busARKit

-- Symlinks for clean code
local busAR = busARCore and busARCore or busARKit
local BusAR_Class = busARCore and evar.BusARCore or evar.BusARKit

if not busAR then
	local msg = "Cannot detect ARKit/ARcore"
	if sys == "android" then
		msg = msg .. "\nPlease install Google Play Services for AR"
	end

	logger:error(msg)
	info_txt.text.value = msg
	info_txt.text.color = osg.Vec4(1.0, 0.0, 0.0, 1.0)

	return
end


local planeFindingMode	= bit_or(BusAR_Class.PLANE_HORIZONTAL, BusAR_Class.PLANE_VERTICAL)
busAR:setPlaneFindingModeMask(planeFindingMode)
-- NOTE: Use busAR:setPlaneFindingModeMask(0) to stop finding planes (will improve performance)


local function showPlane()
	ar_plane_transform:show()
	button:show(bit_or(NodeReactor.Mask.VISIBLE, NodeReactor.Mask.CLICKABLE))
end

local function onPlaneEnter()
	logger:info("Plane entered")
	showPlane()
end

local function onPlaneMove(mat)
	local m = evar.evar2osg(mat, false)
	ar_plane_transform.node:setMatrix(m)
	if not ar_plane_transform.visible then
		showPlane()
	end
end

local function onPlaneLeave()
	logger:info("Plane leave")
	ar_plane_transform:hide(0x0)
	button:hide(0x0)
end

local classification, min_area, min_distance, max_distance = BusAR_Class.MarkerPlane.PLANE_CLASS_NONE, 1.0, 1.0, 5.0
local planeTraits		= BusAR_Class.MarkerPlane.Traits(classification, min_area, min_distance, max_distance)
local markerPlaneImpl	= BusAR_Class.MarkerPlane(planeTraits)	-- markerImpl ref. by the handler

markerImplHandler		= nil			-- handler not ref. by busARCore/busARKit, so create it global, this will be fixed in the future releases
if busARCore then
	markerImplHandler = evar.BusARCore.Marker.HandlerLua(markerPlaneImpl, onPlaneEnter, onPlaneMove, onPlaneLeave)
else
	markerImplHandler = evar.BusARKit.Marker.HandlerLua(markerPlaneImpl, trackingSystem.bus, onPlaneEnter, onPlaneMove, onPlaneLeave)
end
busAR:addListener(markerImplHandler)	-- handler not ref. by busARCore/busARKit
busAR:addMarker(markerPlaneImpl)


ar_plane_transform:subscribeEvent("onShowed", function()
	info_txt:hide()
end)
ar_plane_transform:subscribeEvent("onHidden", function()
	info_txt:show()
end)

button:subscribeEvent("onDown", function()
	if markerPlaneImpl:isTagged() then
		markerPlaneImpl:untag()
		button.text.value = "ПОМЕСТИТЬ"
		plane_image:show()
		plane_model:hide()
	else
		markerPlaneImpl:tag()
		button.text.value = "ПЕРЕМЕСТИТЬ"
		plane_image:hide()
		plane_model:show()
	end
end)
