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

-- EV Toolbox 3.2.0-rc2

RoundRectangle = class("RoundRectangle")
	:field("rectReactor")
	:field("_shaderAttribute")
	:field("_radius")
	:field("_radiusUniform")		-- Vec2f (relative to aspect of rectangle)
	:field("_smoothEdge0")
	:field("_smoothEdge0Uniform")	-- Float

	:property{"radius", getter = "getRadius", setter = "setRadius"}
	:property{"smooth", getter = "getSmooth", setter = "setSmooth"}
:done()

function RoundRectangle:_construct(rectReactor)
	-- TODO: check if rect

	self.rectReactor = rectReactor
	self.rectReactor.rect.drawable:getOrCreateStateSet():setRenderingHint(bit_or(osg.StateSet.TRANSPARENT_BIN))		-- FIXME: dynamic opaque color change

	self:_createShaderAttribute()

	local stateSet = rectReactor.rect.drawable:getOrCreateStateSet()
	stateSet:setAttribute(self._shaderAttribute, osg.StateAttribute.ON)

	local rectSize = self.rectReactor.rect:getBoxSizeRaw()

	self._radius				= 0.5	-- by height
	self._radiusUniform			= osg.Uniform.Vec2f("RoundRectangle_Radius", osg.Vec2(self._radius*rectSize.x/rectSize.y, self._radius))
	self._radiusUniform:setDataVariance(osg.Object.DYNAMIC)

	self._smoothEdge0			= 0.95	-- [0.0, 1.0]
	self._smoothEdge0Uniform	= osg.Uniform.Float("RoundRectangle_smoothEdge0", self._smoothEdge0)
	self._smoothEdge0Uniform:setDataVariance(osg.Object.DYNAMIC)

	stateSet:addUniform(self._radiusUniform)
	stateSet:addUniform(self._smoothEdge0Uniform)
end

function RoundRectangle:setRadius(radius)
	self._radius = radius
	local rectSize = self.rectReactor.rect:getBoxSizeRaw()
	self._radiusUniform:setVec2f(osg.Vec2(self._radius*rectSize.y/rectSize.x, self._radius))
end

function RoundRectangle:setSmoothEdge0(smooth)
	self._smoothEdge0 = smooth
	self._smoothEdge0Uniform:setFloat(self._smoothEdge0)
end

function RoundRectangle:_createShaderAttribute()
	local vshader = osg.Shader(osg.Shader.VERTEX)
	vshader:addCodeInjection(-0.1,
	[[
in vec2 osg_MultiTexCoord0;		// NOTE: no whitespaces before in/out
out vec2 vertex_tc0;
	]])

	vshader:addCodeInjection(0.9,
	[[
		vertex_tc0 = osg_MultiTexCoord0;
	]])

	local fshader = osg.Shader(osg.Shader.FRAGMENT)
	fshader:addCodeInjection(-0.1,
	[[
in vec2 vertex_tc0;
uniform vec2 RoundRectangle_Radius;
uniform float RoundRectangle_smoothEdge0;
	]])
	fshader:addCodeInjection(0.40,
	[[

	const float smooth_value = 0.1;		// TODO: define

	vec2 sz = RoundRectangle_Radius;

	// bottom left
	vec2 bl = vertex_tc0 - sz;
	float r1 = 1.0 - smoothstep(RoundRectangle_smoothEdge0, 1.0, length(min(vec2(0.0), bl)/sz));

	// top left
	vec2 tl = vertex_tc0 - vec2(sz.x, 1.0 - sz.y);
	float r2 = 1.0 - smoothstep(RoundRectangle_smoothEdge0, 1.0, length(vec2(min(0.0, tl.x), max(0.0, tl.y))/sz));

	// top right
	vec2 tr = vertex_tc0 - (vec2(1.0) - sz);
	float r3 = 1.0 - smoothstep(RoundRectangle_smoothEdge0, 1.0, length(max(vec2(0.0), tr)/sz));

	// bottom right
	vec2 br = vertex_tc0 - vec2(1.0 - sz.x, sz.y);
	float r4 = 1.0 - smoothstep(RoundRectangle_smoothEdge0, 1.0, length(vec2(max(0.0, br.x), min(0.0, br.y))/sz));

	sOpacityColor.a *= r1*r2*r3*r4;
	]])

	local component = osg.ShaderComponent()
	component:addShader(vshader);
	component:addShader(fshader);

	self._shaderAttribute = osg.ShaderAttribute()
	self._shaderAttribute:setType(10000 + 1)
	self._shaderAttribute:setShaderComponent(component)
end
