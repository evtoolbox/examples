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

-- EV Toolbox 3.2.0-rc4

local template = osgParticle.Particle()
template:setLifeTime(4)
template:setSizeRange(0.01, 0.025)
template:setMass(100.0)

local system = osgParticle.ParticleSystem()
system:setDefaultParticleTemplate(template)
system:setDefaultAttributes("resources/obj_audio.png", true, false, 0)
system:getOrCreateStateSet():setDefine("EV_GL_OPACITY_FROM_DIFFUSE", osg.StateAttribute.ON)

local emitter = osgParticle.ModularEmitter()
emitter:setParticleSystem(system)

local randomCounter = osgParticle.RandomRateCounter()
randomCounter:setRateRange(500, 1000)
emitter:setCounter(randomCounter)

sceneRoot:addChild(system)
sceneRoot:addChild(emitter)

local updater = osgParticle.ParticleSystemUpdater()
updater:addParticleSystem(system)

sceneRoot:addChild(updater)
