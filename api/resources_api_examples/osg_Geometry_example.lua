-- Example of Geometry object сreation.

-- Creates regular polygon with <verticesCount> vertices and adds it to HUD.
-- The resulting polygon is inscribed in a circle with a radius of <radius>.

local verticesCount		= 6
local radius			= 0.2
local color				= osg.Vec4(1.0, 1.0, 1.0, 1.0)
local lineWidth			= 3	-- NOTE: does not work on macOS
local z					= 0.0

local vertexArray = osg.Vec3Array(verticesCount)
local drawElements = osg.DrawElementsUShort(osg.PrimitiveSet.LINE_LOOP, verticesCount)

local geometry = osg.Geometry()
geometry:setUseVertexBufferObjects(true)
geometry:setVertexArray(vertexArray)
geometry:addPrimitiveSet(drawElements)
geometry:setDataVariance(osg.Object.DYNAMIC)

local uniform = osg.Uniform.Vec4f("ev_MaterialDiffuse", color)
uniform:setDataVariance(osg.Object.DYNAMIC)

local stateSet = geometry:getOrCreateStateSet()
stateSet:setAttributeAndModes(osg.LineWidth(lineWidth))
stateSet:addUniform(uniform)
stateSet:setMode(GLenum.GL_LIGHTING, osg.StateAttribute.OFF)

local step = 2*math.pi/verticesCount
for i = 0, verticesCount - 1 do
	local x = radius*math.cos(math.pi*0.5 + step*i)
	local y = radius*math.sin(math.pi*0.5 + step*i)

	loginfo(string.format("i = %d, deg = %f %.f %.f", i, math.deg(math.pi*0.5 + step*i), x, y))

	drawElements:addElement(i)
	vertexArray:set(i, osg.Vec3(x, y, z))
end

geometry:setNodeMask(0xffffffff)
coreProfileNode(geometry)

local hud = reactorController:getReactorByName("HeadUpDisplay")
hud.node:addChild(geometry)
