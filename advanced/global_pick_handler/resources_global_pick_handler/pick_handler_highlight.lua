-------------------------------------------------------------------------------
--                                                                           --
-- Copyright 2018 EligoVision. Interactive Technologies                      --
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

-- EV Toolbox 3.2.0-beta6
-- Click on the parts of the house to see how it works

-- Setup viewer's camera position
local eye		= osg.Vec3(0, -0.25, 0.15)
local center	= osg.Vec3(0, 0, 0.05)
local up		= osg.Vec3(0, 0, 1)
viewer:getCamera():setViewMatrixAsLookAt(eye, center, up)


-- Highlight function
local ambientIntensityUniform =
		osg.Uniform.Vec4f("ev_LightModelAmbientIntensity", osg.Vec4(1.0, 1.0, 1.0, 1.0))

local lastHighlightedNode
local function highlight(node)
	if lastHighlightedNode then
		lastHighlightedNode:getOrCreateStateSet():removeUniform(ambientIntensityUniform)
	end

	node:getOrCreateStateSet():addUniform(ambientIntensityUniform)
	lastHighlightedNode = node
end

local function onDownCb(nodePath)
	local node = nodePath:at(nodePath:size() - 1)
	loginfo("Down on '" .. node:getName() .."'")
	highlight(node)

	return true
 end

local function onUpCb(nodePath)
	local node = nodePath:at(nodePath:size() - 1)
	loginfo("Up on '" .. node:getName() .."'")
	logwarn("onUpCb not realized!")

 	return true
end

 local observer = EVosgGA.PickHandler.Observer()
 observer:setOnDownCb(onDownCb)
 observer:setOnUpCb(onUpCb)

-- NOTE: pickHandler is global
 pickHandler:registerObserver(observer)
