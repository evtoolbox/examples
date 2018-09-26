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

-- cURL example

-- EV Toolbox 3.2.0-beta4
-- Supported systems: Windows, Linux, Mac
-- Supported protocols: http, https, ftp, ftps

-- Tooltip:
-- cd data/ev_studio/resources
-- python -m SimpleHTTPServer


viewer:setCameraManipulator(osgGA.TrackballManipulator())


local host = "http://0.0.0.0:8000"

--text
local textFile = "test.txt.curl"
local text = evi.getRemoteText(host .. "/" .. textFile)

if text then
	loginfo("Text " .. textFile .. " loaded!")
	loginfo("containment : " .. text)
else
	logerror("Can't read text from " .. host .. "/" ..  textFile)
end

-- model
local modelFile = "models/ev_model.fbx"
local model = osgDB.readNodeFile(host .. "/" .. modelFile)

if model then
	loginfo("Model " .. modelFile .. " loaded!")

	coreProfileNode(model)
	reactorController:getReactorByName("Scene").node:addChild(model)
else
	logerror("Can't read model " .. modelFile)
end


-- image
local imageFile = "images/1.tif"
local imageSource = osgDB.readImageFile(host .. "/" .. imageFile)

local imageReactor = reactorController:getReactorByName("image")
if imageSource then
	loginfo("Image " .. imageFile .. " loaded!")

	imageReactor.image:setImage(imageSource)
else
	logerror("Can't read image " .. imageFile)
end
