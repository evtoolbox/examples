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

vrHeadset = rawget(_G, "vrHeadset")

-- NOTE: The order of inherinance is important!
local BonesInfo =
{
	{ index = bit_or(ovr.ovrHandBone_WristRoot)		, name = "wrist" }
,	{ index = bit_or(ovr.ovrHandBone_ForearmStub)	, name = "forearm_stub" }
,	{ index = bit_or(ovr.ovrHandBone_Thumb0)		, name = "thumb0" }
,	{ index = bit_or(ovr.ovrHandBone_Thumb1)		, name = "thumb1" }
,	{ index = bit_or(ovr.ovrHandBone_Thumb2)		, name = "thumb2" }
,	{ index = bit_or(ovr.ovrHandBone_Thumb3)		, name = "thumb3" }
,	{ index = bit_or(ovr.ovrHandBone_Index1)		, name = "index1" }
,	{ index = bit_or(ovr.ovrHandBone_Index2)		, name = "index2" }
,	{ index = bit_or(ovr.ovrHandBone_Index3)		, name = "index3" }
,	{ index = bit_or(ovr.ovrHandBone_Middle1)		, name = "middle1" }
,	{ index = bit_or(ovr.ovrHandBone_Middle2)		, name = "middle2" }
,	{ index = bit_or(ovr.ovrHandBone_Middle3)		, name = "middle3" }
,	{ index = bit_or(ovr.ovrHandBone_Ring1)			, name = "ring1" }
,	{ index = bit_or(ovr.ovrHandBone_Ring2)			, name = "ring2" }
,	{ index = bit_or(ovr.ovrHandBone_Ring3)			, name = "ring3" }
,	{ index = bit_or(ovr.ovrHandBone_Pinky0)		, name = "pinky0" }
,	{ index = bit_or(ovr.ovrHandBone_Pinky1)		, name = "pinky1" }
,	{ index = bit_or(ovr.ovrHandBone_Pinky2)		, name = "pinky2" }
,	{ index = bit_or(ovr.ovrHandBone_Pinky3)		, name = "pinky3" }
}

-- global
function setupHandModel(aVRController)
	-- NOTE: Hand model must be a child of the controller (in subgraph)
	local controllerType = aVRController.deviceType
	local isLeft	= (controllerType == DeviceType.HAND_LEFT)
	local isRight	= (controllerType == DeviceType.HAND_RIGHT)
	if not isLeft and not isRight then
		logger:error("Cannot setup controller: Type must be left/right hand!")
		return
	end

	local boneNamePrefix = "b_" .. (isRight and "r_" or "l_")
	
	local boneNodesByIndex = {}
	for _, boneInfo in ipairs(BonesInfo) do
		local boneName = boneNamePrefix .. boneInfo.name
		local node = cast(EVosgUtil.findNamedClassNode(boneName, aVRController.node, "Bone"), osgAnimation.Bone)
		if node then
			logger:info("Bone '" .. boneName .. "' found!")
			local initialBonePosition = osg.Vec3(0.0, 0.0, 0.0)*node:getMatrix()
			table.insert(boneNodesByIndex, { index = boneInfo.index, bone = node, initialPosition = initialBonePosition } )
			node:setUpdateCallback(nil)		-- NOTE: remove default callback
			
			-- setup index finger (intersections)
			if boneInfo.name == "index3" then
				local postfix = isLeft and "left" or "right"
				local indexFingerIntersector = reactorController:getReactorByName("intersector_" .. postfix)
				local mt = osg.MatrixTransform()
				mt:setMatrix(osg.Matrix.rotate(math.pi/2, osg.Vec3(0.0, (isLeft and -1.0 or 1.0), 0.0)))
				mt:addChild(indexFingerIntersector.node)
				node:addChild(mt)
			end
		else
			logger:warn("Cannot find bone '" .. boneName .. "'")
		end
	end		

	vrHeadset:subscribe("ControllerMotionEvent", function(_, aControllerType, aExtraData)
		if aControllerType ~= controllerType or not aExtraData then
			return
		end
		
		local handPose = aExtraData["handPose"]
		if not handPose then
			logger:error("No 'handPose' key in the extraData table!")
			return
		end

		for _, indexBone in ipairs(boneNodesByIndex) do
			local rotation = ovr.ovr2osg(handPose:BoneRotations(indexBone.index))
			local mat = osg.Matrix.rotate(rotation)*osg.Matrix.translate(indexBone.initialPosition)

			local node = indexBone.bone
			node:setMatrix(mat)

			local parent = node:getBoneParent()
			local matrixInSkeletonSpace = parent and mat*parent:getMatrixInSkeletonSpace() or mat
			node:setMatrixInSkeletonSpace(matrixInSkeletonSpace)
		end
	end)
end
