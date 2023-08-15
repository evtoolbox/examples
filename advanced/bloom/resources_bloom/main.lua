-------------------------------------------------------------------------------
--                                                                           --
-- Copyright 2022-2023 EligoVision. Interactive Technologies                 --
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

-- NOTE: Should work on desktops with OpenGL 3.2 and upper,
--       Generic GLES3-devices (tested on Pixel 4 XL)

local hostOperationSystem, softwarePlatform = evi.os()

-- TODO: local
isGLES =
	hostOperationSystem == "android" or
	hostOperationSystem == "ios" or
	softwarePlatform == "web"


local bloomModule = require "bloom.lua"


-- NOTE: Resolution scale factor. Try 1.0, 1/4, 1/8 as instance, should NOT be greater than 1.0!
local resolutionScale	= isGLES and 0.5 or 1.0
local samples			= isGLES and 0 or 4
local blurPasses		= 5

bloomModule.setupCameraBloom(viewer:getCamera(), resolutionScale, samples, blurPasses)


-- Some optimizations, tuning, statistics:

local scene = reactorController:getReactorByName("Scene")
scene.node:getOrCreateStateSet():setMode(GLenum.GL_CULL_FACE, osg.StateAttribute.ON)

bus:subscribeOnce(function()
	-- viewer:getCamera():setClearColor(osg.Vec4(0.0, 0.0, 0.0, 0.0))
	-- viewer:getCamera():setClearMask(bit_or(GLenum.GL_COLOR_BUFFER_BIT, GLenum.GL_DEPTH_BUFFER_BIT))
	statsHandler:setLevel(3)
end)
