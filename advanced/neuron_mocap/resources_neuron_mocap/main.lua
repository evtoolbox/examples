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

-- EV Toolbox 3.4.0

-- NOTE: Use AXIS NEURON (QtAxis) Broadcasting with
--       'Output Format' =  Rotation = YXZ, Displacement = YES
--       + ev_neuronmocap_transmitter tool
--       Example: ./ev_neuronmocap_transmitter localhost 7006 localhost 12345

CFG_SERVER_PORT = 12345

local logger = set_logger("ev_evi.lua.neuronmocap")

BonesInfo	= {} -- Globals 'BonesInfo' inited in BonesInfo.lua
Bones		= { --[[ { name -> string, node -> osgAnimation.Bone, data -> {x, y, z, ry, rx, rz} }]]}

require("registerPlugin.lua")
require("BonesInfo.lua")
require("server.lua")

EV.Logger.setCatPriority("ev_evi.lua.neuronmocap"					, "INFO");
EV.Logger.setCatPriority("ev_evi.lua.neuronmocap.registerPlugins"	, "INFO");
EV.Logger.setCatPriority("ev_evi.lua.neuronmocap.server"			, "DEBUG");

local skeletonNode = reactorController:getReactorByName("skeleton").node

skeletonNode:setCullingActive(false)

local function calcBoneMatrix(x, y, z, ry, rx, rz)
	-- TODO: optimize
	-- NOTE: neuronmocap units are cm and degrees, we are in metres and radians
	return	osg.Matrix.rotate(osg.Quat(rz/180.0*math.pi, osg.Vec3(0.0, 0.0, 1.0))
							* osg.Quat(rx/180.0*math.pi, osg.Vec3(1.0, 0.0, 0.0))
							* osg.Quat(ry/180.0*math.pi, osg.Vec3(0.0, 1.0, 0.0)))
			* osg.Matrix.translate(osg.Vec3(x, y, z)*0.01)
end

for i, boneInfo in ipairs(BonesInfo) do
	local node = cast(EVosgUtil.findNamedClassNode(boneInfo.name, skeletonNode, "Bone"), osgAnimation.Bone)
	if not node then
		logger:warn("Cannot find bone '" .. boneName .. "'")
		-- error()
	else
		logger:info("Bone '" .. boneInfo.name .. "' found!")
		Bones[i] = { name = boneInfo.name, node = node, data = nil }

		local updateBone = osg.NodeCallback(function(aNode, aNodeVisitor)
			local data = Bones[i].data
			if not data then
				return
			end

			local mat = calcBoneMatrix(data.x, data.y, data.z, data.ry, data.rx, data.rz)

			node:setMatrix(mat)

			local parent = node:getBoneParent()
			if parent then
				node:setMatrixInSkeletonSpace(mat*parent:getMatrixInSkeletonSpace())
			else
				node:setMatrixInSkeletonSpace(mat)
			end

			Bones[i].mat = nil	-- wait for update
		end)

		node:setUpdateCallback(updateBone)
	end
end

createAndStartServer()

viewer:getCamera():setComputeNearFarMode(osg.CullSettings.DO_NOT_COMPUTE_NEAR_FAR)
