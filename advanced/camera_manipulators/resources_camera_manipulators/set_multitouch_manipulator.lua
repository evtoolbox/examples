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

-- Simple particle system example

-- EV Toolbox 3.2.0-beta6

loginfo("Enabling multitouch manipulator...")

local eye, center, up =
		osg.Vec3(-0.25, -0.25, 0.1),
		osg.Vec3(0.0, 0.0, 0.0),
		osg.Vec3(0.0, 0.0, 1.0);

local multitouchManipulator = EVosgGA.MultiTouchManipulator()
multitouchManipulator:setVerticalAxisFixed(false)
multitouchManipulator:setMinimumDistance(0.05)
multitouchManipulator:setMaximumDistance(10.0)
multitouchManipulator:setHomePosition(eye, center, up, false)

viewer:setCameraManipulator(multitouchManipulator)
multitouchManipulator:home(0.0)

loginfo("Multitouch manipulator enabled!")
