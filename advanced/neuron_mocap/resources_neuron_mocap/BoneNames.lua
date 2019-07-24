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

local logger = set_logger("ev_evi.lua.neuronmocap")

BoneNames = {
	-- Body
	"Hips",
	
	"RightUpLeg",
	"RightLeg",
	"RightFoot",

	"LeftUpLeg",
	"LeftLeg",
	"LeftFoot",

	"Spine",
	"Spine1",
	"Spine2",
	"Spine3",

	"Neck",
	"Head",

	"RightShoulder",
	"RightArm",
	"RightForeArm",
	"RightHand",
	
	-- Fingers
	"RightHandThumb1",
	"RightHandThumb2",
	"RightHandThumb3",

	"RightInHandIndex",
	"RightHandIndex1",
	"RightHandIndex2",
	"RightHandIndex3",

	"RightInHandMiddle",
	"RightHandMiddle1",
	"RightHandMiddle2",
	"RightHandMiddle3",

	"RightInHandRing",
	"RightHandRing1",
	"RightHandRing2",
	"RightHandRing3",

	"RightInHandPinky",
	"RightHandPinky1",
	"RightHandPinky2",
	"RightHandPinky3",
	
	-- Body
	"LeftShoulder",
	"LeftArm",
	"LeftForeArm",
	"LeftHand",

	-- Fingers
	"LeftHandThumb1",
	"LeftHandThumb2",
	"LeftHandThumb3",

	"LeftInHandIndex",
	"LeftHandIndex1",
	"LeftHandIndex2",
	"LeftHandIndex3",

	"LeftInHandMiddle",
	"LeftHandMiddle1",
	"LeftHandMiddle2",
	"LeftHandMiddle3",
	
	"LeftInHandRing",
	"LeftHandRing1",
	"LeftHandRing2",
	"LeftHandRing3",

	"LeftInHandPinky",
	"LeftHandPinky1",
	"LeftHandPinky2",
	"LeftHandPinky3",
}