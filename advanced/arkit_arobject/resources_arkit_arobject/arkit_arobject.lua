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

-- EV Toolbox 3.4.12 required
-- Docs: https://eligovision.ru/toolbox/docs/3.4/API/interfaces/evar2/pkg_evar2.html

local logger = set_lua_logger("arkit_arobject")

-- Initial state
local matrixTransform = reactorController:getReactorByName("arobject_transform").node
matrixTransform:setNodeMask(0x0)


-- NOTE: trackingSystem is global (used by TrackingSystemReactor also)
local busARKit	= trackingSystem.busARKit

if not busARKit then
    logger:error("Cannot detect ARKit!")

    return
end


local function onEnter()
	logger:info("onEnter")
	matrixTransform:setNodeMask(0xffffffff)
end

local function onMove(mat)
	logger:info("onMove")
	matrixTransform:setNodeMask(0xffffffff)
	matrixTransform:setMatrix(evar.evar2osg(mat, false))
end

local function onLeave()
	logger:info("onLeave")
    matrixTransform:setNodeMask(0x0)
end


-- NOTE: Pico4.arobject must be in the Assets (checkbox in the Properties of the Resource)
local marker = evar.BusARKit.MarkerImage("Pico4.arobject", "anchor_pico4")  -- NOTE: Can be renamed in the future releases

-- handler not ref. by busARCore/busARKit, so create it global, this will be fixed in the future releases
handler = evar.BusARKit.Marker.HandlerLua(marker, trackingSystem.bus, onEnter, onMove, onLeave)

busARKit:addListener(handler)
busARKit:addMarker(marker)
