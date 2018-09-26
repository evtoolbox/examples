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

-- EV Toolbox 3.2.0-beta4

loginfo("Enabling terrain manipulator...")

local eye, center, up =
		osg.Vec3(-0.25, -0.25, 0.1),
		osg.Vec3(0.0, 0.0, 0.0),
		osg.Vec3(0.0, 0.0, 1.0);

local terrainManipulator = EVosgGA.TerrainManipulator()
terrainManipulator:setWheelZoomFactor(0.005)	-- default is 0.5%
terrainManipulator:setHomePosition(eye, center, up, false)
terrainManipulator:setVerticalAxisFixed(true)
terrainManipulator:setAllowThrow(false)
terrainManipulator:setAnimationTime(0)

viewer:setCameraManipulator(terrainManipulator)
terrainManipulator:home(0.0)

loginfo("Terrain manipulator enabled!")
