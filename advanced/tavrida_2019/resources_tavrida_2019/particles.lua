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
template:setLifeTime(2.5)
template:setSizeRange(0.15, 0.0)
template:setMass(100.0)

local system = osgParticle.ParticleSystem()
system:setDefaultParticleTemplate(template)
system:setDefaultAttributes("resources/particle.png", true, false, 0)
system:getOrCreateStateSet():setDefine("EV_GL_OPACITY_FROM_DIFFUSE", osg.StateAttribute.ON)
system:getOrCreateStateSet():setDefine("EV_GL_LIGHTING", osg.StateAttribute.OFF)

local updater = osgParticle.ParticleSystemUpdater()
updater:addParticleSystem(system)

sceneRoot:addChild(system)
sceneRoot:addChild(updater)

function addParticles(controlNode)

	local emitter = osgParticle.ModularEmitter()
	emitter:setParticleSystem(system)

	local shooter = osgParticle.RadialShooter()
	shooter:setInitialSpeedRange(0.0, 0.05)
	shooter:setInitialRotationalSpeedRange(osg.Vec3(0, 0, 0), osg.Vec3(1, 1, 1))
	emitter:setShooter(shooter)

	local randomCounter = osgParticle.RandomRateCounter()
	randomCounter:setRateRange(50, 70)
	emitter:setCounter(randomCounter)


	local particlesTransform = osg.MatrixTransform()
	particlesTransform:setUpdateCallback(osg.NodeCallback(function(node, nv)
		particlesTransform:setMatrix(controlNode:getWorldMatrices():at(0))
	end))
	particlesTransform:addChild(emitter)

	sceneRoot:addChild(particlesTransform)
end
