-- Example of Geometry object creation.

-- Creates regular polygon with <verticesCount> vertices and adds it to HUD.
-- The resulting polygon is inscribed in a circle with a radius of <radius>.

local verticesCount		= 6
local radius			= 0.2
local color				= osg.Vec4(1.0, 1.0, 1.0, 1.0)
local lineWidth			= 3		-- NOTE: Ignored on macOS (not supported in OpenGL Core Profile)
local z					= 0.0

local vertexArray = osg.Vec3Array(verticesCount)
local drawElements = osg.DrawElementsUShort(osg.PrimitiveSet.LINE_LOOP, verticesCount)

local geometry = osg.Geometry()
geometry:setUseVertexBufferObjects(true)
geometry:setVertexArray(vertexArray)
geometry:addPrimitiveSet(drawElements)

-- NOTE: Must be marked as DYNAMIC if you need to change vertexArray later
-- geometry:setDataVariance(osg.Object.DYNAMIC)

local uniform = osg.Uniform.Vec4f("ev_MaterialDiffuse", color)
-- NOTE: Should be marked as DYNAMIC (for optimization purposes)
uniform:setDataVariance(osg.Object.DYNAMIC)

local stateSet = geometry:getOrCreateStateSet()
stateSet:setAttributeAndModes(osg.LineWidth(lineWidth))
stateSet:addUniform(uniform)
stateSet:setMode(GLenum.GL_LIGHTING, osg.StateAttribute.OFF)	-- Disable lighting

local step = 2*math.pi/verticesCount
for i = 0, verticesCount - 1 do
	local x = radius*math.cos(math.pi*0.5 + step*i)
	local y = radius*math.sin(math.pi*0.5 + step*i)

	loginfo(string.format("i = %d, deg = %f %.f %.f", i, math.deg(math.pi*0.5 + step*i), x, y))

	drawElements:addElement(i)
	vertexArray:set(i, osg.Vec3(x, y, z))
end

-- geometry:setNodeMask(0xffffffff)	-- mask can be changed
-- coreProfileNode(geometry)		-- no need (will be called before first Viewer's frame)

local hud = reactorController:getReactorByName("HeadUpDisplay")	-- must be presented in the project
hud.node:addChild(geometry)
