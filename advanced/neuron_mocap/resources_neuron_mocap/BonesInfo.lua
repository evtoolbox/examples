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

BonesInfo = {
	-- Body
	{ name = "Hips"						, offset = osg.Vec3(0.00	, 104.19	, 0.00) },

	{ name = "RightUpLeg"				, offset = osg.Vec3(-11.50	, 0.00		, 0.00) },
	{ name = "RightLeg"					, offset = osg.Vec3(0.00	, -48.00	, 0.00) },
	{ name = "RightFoot"				, offset = osg.Vec3(0.00	, -48.00	, 0.00) },

	{ name = "LeftUpLeg"				, offset = osg.Vec3(11.50	, 0.00		, 0.00) },
	{ name = "LeftLeg"					, offset = osg.Vec3(0.00	, -48.00	, 0.00) },
	{ name = "LeftFoot"					, offset = osg.Vec3(0.00	, -48.00	, 0.00) },

	{ name = "Spine"					, offset = osg.Vec3(0.00	, 13.88		, 0.00) },
	{ name = "Spine1"					, offset = osg.Vec3(0.00	, 11.31		, 0.00) },
	{ name = "Spine2"					, offset = osg.Vec3(0.00	, 11.78		, 0.00) },
	{ name = "Spine3"					, offset = osg.Vec3(0.00	, 11.31		, 0.00) },

	{ name = "Neck"						, offset = osg.Vec3(0.00	, 12.09		, 0.00) },
	{ name = "Head"						, offset = osg.Vec3(0.00	, 9.00		, 0.00) },

	{ name = "RightShoulder"			, offset = osg.Vec3(-3.50	, 8.06		, 0.00) },
	{ name = "RightArm"					, offset = osg.Vec3(-17.50	, 0.00		, 0.00) },
	{ name = "RightForeArm"				, offset = osg.Vec3(-29.00	, 0.00		, 0.00) },
	{ name = "RightHand"				, offset = osg.Vec3(-28.00	, 0.00		, 0.00) },

	-- Fingers
	{ name = "RightHandThumb1"			, offset = osg.Vec3(-2.70	, 0.21		, 3.39) },
	{ name = "RightHandThumb2"			, offset = osg.Vec3(-2.75	, -0.64		, 2.83) },
	{ name = "RightHandThumb3"			, offset = osg.Vec3(-2.13	, -0.81		, 1.59) },

	{ name = "RightInHandIndex"			, offset = osg.Vec3(-3.50	, 0.55		, 2.15) },
	{ name = "RightHandIndex1"			, offset = osg.Vec3(-5.67	, -0.10		, 1.09) },
	{ name = "RightHandIndex2"			, offset = osg.Vec3(-3.92	, -0.19		, 0.20) },
	{ name = "RightHandIndex3"			, offset = osg.Vec3(-2.22	, -0.14		, -0.08) },

	{ name = "RightInHandMiddle"		, offset = osg.Vec3(-3.67	, 0.56		, 0.82) },
	{ name = "RightHandMiddle1"			, offset = osg.Vec3(-5.62	, -0.09		, 0.34) },
	{ name = "RightHandMiddle2"			, offset = osg.Vec3(-4.27	, -0.29		, -0.20) },
	{ name = "RightHandMiddle3"			, offset = osg.Vec3(-2.67	, -0.21		, -0.24) },

	{ name = "RightInHandRing"			, offset = osg.Vec3(-3.65	, 0.59		, -0.14) },
	{ name = "RightHandRing1"			, offset = osg.Vec3(-5.00	, -0.02		, -0.52) },
	{ name = "RightHandRing2"			, offset = osg.Vec3(-3.65	, -0.29		, -0.74) },
	{ name = "RightHandRing3"			, offset = osg.Vec3(-2.55	, -0.19		, -0.44) },

	{ name = "RightInHandPinky"			, offset = osg.Vec3(-3.43	, 0.51		, -1.30) },
	{ name = "RightHandPinky1"			, offset = osg.Vec3(-4.49	, -0.02		, -1.18) },
	{ name = "RightHandPinky2"			, offset = osg.Vec3(-2.85	, -0.16		, -0.90) },
	{ name = "RightHandPinky3"			, offset = osg.Vec3(-1.77	, -0.14		, -0.66) },

	-- Body
	{ name = "LeftShoulder"				, offset = osg.Vec3(3.50	, 8.06		, 0.00) },
	{ name = "LeftArm"					, offset = osg.Vec3(17.50	, 0.00		, 0.00) },
	{ name = "LeftForeArm"				, offset = osg.Vec3(29.00	, 0.00		, 0.00) },
	{ name = "LeftHand"					, offset = osg.Vec3(28.00	, 0.00		, 0.00) },

	-- Fingers
	{ name = "LeftHandThumb1"			, offset = osg.Vec3(2.70	, 0.21		, 3.39) },
	{ name = "LeftHandThumb2"			, offset = osg.Vec3(2.75	, -0.64		, 2.83) },
	{ name = "LeftHandThumb3"			, offset = osg.Vec3(2.13	, -0.81		, 1.59) },

	{ name = "LeftInHandIndex"			, offset = osg.Vec3(3.50	,  0.55		, 2.15) },
	{ name = "LeftHandIndex1"			, offset = osg.Vec3(5.67	,  -0.10	, 1.08) },
	{ name = "LeftHandIndex2"			, offset = osg.Vec3(3.92	,  -0.19	, 0.20) },
	{ name = "LeftHandIndex3"			, offset = osg.Vec3(2.22	,  -0.14	, -0.08) },

	{ name = "LeftInHandMiddle"			, offset = osg.Vec3(3.67	, 0.56		, 0.82) },
	{ name = "LeftHandMiddle1"			, offset = osg.Vec3(5.62	, -0.09		, 0.34) },
	{ name = "LeftHandMiddle2"			, offset = osg.Vec3(4.27	, -0.29		, -0.20) },
	{ name = "LeftHandMiddle3"			, offset = osg.Vec3(2.67	, -0.21		, -0.24) },

	{ name = "LeftInHandRing"			, offset = osg.Vec3(3.65	, 0.59		, -0.14) },
	{ name = "LeftHandRing1"			, offset = osg.Vec3(5.00	, -0.02		, -0.52) },
	{ name = "LeftHandRing2"			, offset = osg.Vec3(3.65	, -0.29		, -0.74) },
	{ name = "LeftHandRing3"			, offset = osg.Vec3(2.55	, -0.19		, -0.44) },

	{ name = "LeftInHandPinky"			, offset = osg.Vec3(3.43	, 0.51		, -1.30) },
	{ name = "LeftHandPinky1"			, offset = osg.Vec3(4.49	, -0.02		, -1.18) },
	{ name = "LeftHandPinky2"			, offset = osg.Vec3(2.85	, -0.16		, -0.90) },
	{ name = "LeftHandPinky3"			, offset = osg.Vec3(1.77	, -0.14		, -0.66) },
}

