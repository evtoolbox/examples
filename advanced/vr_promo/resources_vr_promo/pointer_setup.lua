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

-- local selectionUniform = osg.Uniform.Vec4f("ev_LightModelAmbientIntensity", osg.Vec4(2.0, 1.0, -1.0, 0.9))
-- selectionUniform:setDataVariance(osg.Object.DYNAMIC)

local reactors = {
	reactorController:getReactorByName("object/timer"),
	reactorController:getReactorByName("object/image"),
	reactorController:getReactorByName("object/text"),
	reactorController:getReactorByName("object/audio"),
	reactorController:getReactorByName("object/counter"),
	reactorController:getReactorByName("object/model"),
}
local lastSelectedReactor = nil
local function onDownImpl(reactor)
	reactor:onDown()
	-- FIXME: right now we do not process controller's buttons' state
	--		so we send "onClick" event with the first time intersection
	reactor:onClick()
end
local function handle(intersections)
	for _, intersection in ipairs(intersections) do
		local nodePath = intersection:nodePath()
		for _, reactor in ipairs(reactors) do
			for i = nodePath:size() - 1, 0, -1 do
				local nodeName = nodePath:at(i):name()
				if reactor.id == nodeName then
					logdebug("Intersect", reactor.name)
					if lastSelectedReactor then
						if lastSelectedReactor.id == reactor.id then
							-- reactor:onMove()
						else
							lastSelectedReactor:onUp()
							onDownImpl(reactor)
							lastSelectedReactor = reactor
						end
					else
						onDownImpl(reactor)
						lastSelectedReactor = reactor
					end

					return intersection
				end
			end
		end
	end
end

--[[
local modelResource = resourceRepository:getResourceByName("vive_focus_controller.FBX")
local controllerModel = resourceRepository:loadResource(modelResource, "osgModel")
local focusController = Pointer(controllerModel)
focusController.onIntersectionsCallback = handle

local scene = reactorController:getReactorByName("Scene")
scene.node:addChild(focusController.root)
if evi.os() ~= "android" then
	viewer:addEventHandler(focusController.mouseHandler)
end
--]]
