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

function fixRenderBin(aRootNode, aMask, aShift)
	aMask = aMask or "_rb_"
	aShift = aShift or 0
	local nv = osg.NodeVisitor(osg.NodeVisitor.TRAVERSE_ALL_CHILDREN)
	nv:setApplyNodeCb(function(node)
		local i = string.find(node:name(), aMask)
		logerror("'" .. node:name() .. "'")
		logwarn(i, string.len(aMask))
		local rb = i and tonumber(string.sub(node:name(), i + string.len(aMask)))
		if rb then
			node:getOrCreateStateSet():setRenderBinDetails(rb + aShift, "RenderBin", osg.StateSet.USE_RENDERBIN_DETAILS)
		end
		nv:traverse(node)
	end)
	aRootNode:accept(nv)
end

local scene = reactorController:getReactorByName("Scene")
fixRenderBin(scene.node, "rb_", 22)
