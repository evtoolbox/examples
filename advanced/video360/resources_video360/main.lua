
local sphere	= reactorController:getReactorByName("sphere_equirectangular")
local video360	= reactorController:getReactorByName("video360")

local video360StateSet = video360.image.stateSet

local sphereStateSet = sphere.node:getOrCreateStateSet()
sphereStateSet:setAttributeAndModes(osg.CullFace(), osg.StateAttribute.ON)
sphereStateSet:setMode(GLenum.GL_LIGHTING, osg.StateAttribute.OFF)
sphereStateSet:setMode(GLenum.GL_LIGHT0, osg.StateAttribute.OFF)

local sphereGeometry = EVosgUtil.findNamedClassNode("Sphere001", sphere.node, "Geometry")
sphereGeometry:setStateSet(video360StateSet)

video360:play()
