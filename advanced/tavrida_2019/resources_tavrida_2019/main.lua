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

EV.Logger.setCatPriority("ev_evi.lua.neuronmocap"					, "INFO");
EV.Logger.setCatPriority("ev_evi.lua.neuronmocap.registerPlugins"	, "INFO");
EV.Logger.setCatPriority("ev_evi.lua.neuronmocap.server"			, "DEBUG");

Bones		= { --[[ { name -> string, node -> osgAnimation.Bone, data -> {x, y, z, ry, rx, rz} }]]}

require("BonesInfo.lua")
require("registerPlugin.lua")
require("server.lua")

local scene = reactorController:getReactorByName("Scene")

scene.node:getOrCreateStateSet():setDefine("EV_GL_LIGHTING_DOUBLE_SIDED", osg.StateAttribute.ON)
scene.node:setCullingActive(false)

local function calcBoneMatrix(pos, ry, rx, rz)
	-- NOTE: neuronmocap units are cm and degrees, we are in metres and radians

	-- Base version
	-- return	osg.Matrix.rotate(osg.Quat(math.rad(rz), osg.Vec3(0.0, 0.0, 1.0))
	-- 						* osg.Quat(math.rad(rx), osg.Vec3(1.0, 0.0, 0.0))
	-- 						* osg.Quat(math.rad(ry), osg.Vec3(0.0, 1.0, 0.0)))
	-- 		* osg.Matrix.translate(pos)

	-- Optimized version
	-- http://www.songho.ca/opengl/gl_anglestoaxes.html
	local a = math.rad(rx)
	local b = math.rad(ry)
	local c = math.rad(rz)

	local sa = math.sin(a)
	local ca = math.cos(a)
	local sb = math.sin(b)
	local cb = math.cos(b)
	local sc = math.sin(c)
	local cc = math.cos(c)

	local a00 = cb*cc + sb*sa*sc
	local a01 = ca*sc
	local a02 = cb*sa*sc - sb*cc

	local a10 = sb*sa*cc - cb*sc
	local a11 = ca*cc
	local a12 = sb*sc + cb*sa*cc

	local a20 = sb*ca
	local a21 = -sa
	local a22 = cb*ca

	return	osg.Matrix(		a00		, 	a01		,	a02		,	0
						,	a10		, 	a11		, 	a12		,	0
						,	a20		, 	a21		, 	a22		,	0
						,	pos:x()	,	pos:y()	,	pos:z()	,	1)

end

local function mocapNode(skeletonNode)
	for i, boneInfo in ipairs(BonesInfo) do
		local node = cast(EVosgUtil.findNamedClassNode(boneInfo.name, skeletonNode, "Bone"), osgAnimation.Bone)
		if not node then
			logger:warn("Cannot find bone '" .. boneName .. "'")
			-- error()
		else
			logger:info("Bone '" .. boneInfo.name .. "' found!")
			Bones[i] = { name = boneInfo.name, node = node, data = nil }

			local initialBonePosition = boneInfo.name ~= "Hips" and osg.Vec3(0.0, 0.0, 0.0)*node:getMatrix()

			local updateBone = osg.NodeCallback(function(aNode, aNodeVisitor)
				local data = Bones[i].data
				if not data then
					return
				end

				local position = initialBonePosition or osg.Vec3(data.x, data.y, data.z)*0.01
				local mat = calcBoneMatrix(position, data.ry, data.rx, data.rz)

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
end

local aliceNode = reactorController:getReactorByName("alice").node
local card_10b = reactorController:getReactorByName("card_10b").node
local queen = reactorController:getReactorByName("queen").node

bus:subscribeOnce(function()
	mocapNode(aliceNode)
	mocapNode(card_10b)
	mocapNode(queen)
end)


viewer:getCamera():setComputeNearFarMode(osg.CullSettings.DO_NOT_COMPUTE_NEAR_FAR)

createAndStartServer()

