-------------------------------------------------------------------------------
--                                                                           --
-- Copyright 2020-2021 EligoVision. Interactive Technologies                 --
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

-- EV Toolbox 3.3.0-beta2 required

local logger = set_logger("ev_evi.lua.app.vr_hands")

local scene = reactorController:getReactorByName("Scene")
local sceneStateSet = scene.node:getOrCreateStateSet()
sceneStateSet:setMode(GLenum.GL_CULL_FACE, osg.StateAttribute.ON)	-- Optimization

if ovr then
	require "hand_skeleton.lua"

	local handLeft = reactorController:getReactorByName("vr_controller_left")
	local handRight = reactorController:getReactorByName("vr_controller_right")

	local pointerLeft = reactorController:getReactorByName("pointer_container_left")
	local pointerRight = reactorController:getReactorByName("pointer_container_right")

	local function customizeHandNode(aController)
		local node = aController.node
		local ss = node:getOrCreateStateSet()

		local visibilityUniform = ss:getOrCreateUniform("ev_Visibility", osg.Uniform.FLOAT)
		visibilityUniform:setDataVariance(osg.Object.DYNAMIC)
		visibilityUniform:setFloat(0.5)
		ss:setMode(GLenum.GL_BLEND, osg.StateAttribute.ON)

		-- NOTE: vrHeadset is global
		vrHeadset:subscribe("ControllerMotionEvent", function(_, aControllerType, aExtraData)
			if aControllerType ~= aController.deviceType then
				return
			end

			-- NOTE: aExtraData is the table with "hand data" (can be changed in the future releases!)
			-- local inputStateHand = aExtraData["inputStateHand"]
			local handPose = aExtraData["handPose"]
			if not handPose then
				logger:error("No 'handPose' key in the extraData table!")
				return
			end

			-- TODO: Smooth visibility animation
			local connectionIsGood = (handPose:HandConfidence() ~= ovr.ovrConfidence_LOW)
			if connectionIsGood then
				visibilityUniform:setFloat(0.5)
			else
				visibilityUniform:setFloat(0.05)
			end
		end)

		-- NOTE: Working on SingleThreaded only (or must be wrapped in lane in future EVTx releases)
		-- Prevent ugly transparency
		local ss1 = osg.StateSet()
		ss1:setAttributeAndModes(osg.ColorMask(false, false, false, false))
		ss1:setAttributeAndModes(osg.Depth(osg.Depth.LESS, 0.0, 1.0, true))

		local ss2 = osg.StateSet()
		ss2:setAttributeAndModes(osg.ColorMask(true, true, true, true))
		ss2:setAttributeAndModes(osg.Depth(osg.Depth.EQUAL, 0.0, 1.0, false))

		node:setCullCallback(osg.NodeCallback(function(node, nv)
			local cv = cast(nv, osgUtil.CullVisitor)	-- TODO: asCullVisitor
			cv:pushStateSet(ss1)
			node:traverse(cv)
			cv:popStateSet()
			cv:pushStateSet(ss2)
			node:traverse(cv)
			cv:popStateSet()

			return true
		end))	
	end
	customizeHandNode(handLeft)
	customizeHandNode(handRight)

	bus:subscribeOnce(function()
		setupHandModel(handLeft)
		setupHandModel(handRight)
	end)	
	
end
