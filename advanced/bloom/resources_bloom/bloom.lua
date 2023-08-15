-------------------------------------------------------------------------------
--                                                                           --
-- Copyright 2022-2023 EligoVision. Interactive Technologies                 --
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

local g = require("base/util/graphics.lua")

logger = set_lua_logger("bloom.bloom")

local function createBloomBrightnessShaderAttribute()
	-- TODO: brightnessThreshold uniform
	local fshader = osg.Shader(osg.Shader.FRAGMENT)
	fshader:addCodeInjection(-0.1,
	[[
	out vec4 Out_ColorBright;	// Bloom
	]])
	fshader:addCodeInjection(1.0,
	[[
	// Bloom [begin]
	{
		float brightness = dot(Out_Color.rgb, vec3(0.2126, 0.7152, 0.0722));
		if (brightness > 0.75)
			Out_ColorBright = vec4(Out_Color.rgb, 1.0);
		else
			Out_ColorBright = vec4(0.0, 0.0, 0.0, 1.0);
	}
	// Bloom [end]
	]])

	local component = osg.ShaderComponent()
	component:addShader(fshader);

	local shaderAttribute = osg.ShaderAttribute()
	shaderAttribute:setType(osg.StateAttribute.Type(10000 + 2))
	shaderAttribute:setShaderComponent(component)

	return shaderAttribute
end

local shaderVersionHeader =  "#version " .. (isGLES and "300 es" or "330 core")

-- This vertex shader is used in more than one program
local vshader = osg.Shader(osg.Shader.VERTEX,
shaderVersionHeader ..
[[

in vec4			osg_Vertex;
in vec4			osg_MultiTexCoord0;
uniform mat4	osg_ModelViewProjectionMatrix;
out vec2		Vertex_Diffuse0UV;

void main()
{
	Vertex_Diffuse0UV = osg_MultiTexCoord0.xy;
	gl_Position = osg_ModelViewProjectionMatrix*osg_Vertex;
}
]])

local function createGaussianBlurShaderProgram()
	local fshader = osg.Shader(osg.Shader.FRAGMENT,
	shaderVersionHeader ..
	[[

in vec2				Vertex_Diffuse0UV;
uniform sampler2D	ev_Diffuse0Tex;
uniform bool		horizontal;
out vec4			Out_Color;

const float			weight[5] = float[](0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216);

void main()
{
	vec2 tex_offset = vec2(1.0)/ vec2(textureSize(ev_Diffuse0Tex, 0));			// gets size of single texel (optimize!)
	vec3 result = texture(ev_Diffuse0Tex, Vertex_Diffuse0UV).rgb * weight[0];	// current fragment's contribution
	if (horizontal)
	{
		for (int i = 1; i < 5; ++i)
		{
			result += texture(ev_Diffuse0Tex, Vertex_Diffuse0UV + vec2(tex_offset.x * float(i), 0.0)).rgb * weight[i];
			result += texture(ev_Diffuse0Tex, Vertex_Diffuse0UV - vec2(tex_offset.x * float(i), 0.0)).rgb * weight[i];
		}
	}
	else
	{
		for (int i = 1; i < 5; ++i)
		{
			result += texture(ev_Diffuse0Tex, Vertex_Diffuse0UV + vec2(0.0, tex_offset.y * float(i))).rgb * weight[i];
			result += texture(ev_Diffuse0Tex, Vertex_Diffuse0UV - vec2(0.0, tex_offset.y * float(i))).rgb * weight[i];
		}
	}

	Out_Color = vec4(result, 1.0);
}
	]])

	local shaderProgram = osg.Program()
	shaderProgram:addShader(vshader)
	shaderProgram:addShader(fshader)

	return shaderProgram
end

local function createBloomOutShaderProgram()
	local fshader = osg.Shader(osg.Shader.FRAGMENT,
	shaderVersionHeader ..
	[[

#pragma import_defines(EV_PP_BLOOM_ENABLE_HDR)

in vec2				Vertex_Diffuse0UV;
uniform sampler2D	ev_Diffuse0Tex;
uniform sampler2D	ev_Opacity0Tex;
uniform float		exposure;
out vec4			Out_Color;


void main()
{
	vec3 baseColor = texture(ev_Diffuse0Tex, Vertex_Diffuse0UV).rgb;
	vec3 bloomColor = texture(ev_Opacity0Tex, Vertex_Diffuse0UV).rgb;

	baseColor += 1.0*bloomColor;							// additive blending (with coeff)

#if defined(EV_PP_BLOOM_ENABLE_HDR)
	vec3 result = vec3(1.0) - exp(-baseColor * exposure);	// tone mapping
	Out_Color = vec4(result, 1.0);
#else
	Out_Color = vec4(baseColor, 1.0);
#endif
}
	]])

	local shaderProgram = osg.Program()
	shaderProgram:addShader(vshader)
	shaderProgram:addShader(fshader)

	return shaderProgram
end


local function createCameraFrontFace(graphicsContext, viewport, name)
	local quad = osg.createTexturedQuadGeometry(osg.Vec3(0.0, 0.0, 0.0),
												osg.Vec3(1.0, 0.0, 0.0),
												osg.Vec3(0.0, 1.0, 0.0))
	quad:setColorArray(nil)

	local cam_ff = osg.Camera() -- Front Face Camera
	cam_ff:setName(name or "front_face")
	if graphicsContext then
		cam_ff:setGraphicsContext(graphicsContext)
	end
	if viewport then
		cam_ff:setViewport(viewport)
	end
	cam_ff:setReferenceFrame(osg.Transform.ABSOLUTE_RF)
	cam_ff:setProjectionMatrixAsOrtho2D(0.0, 1.0, 0.0, 1.0)
	cam_ff:setAllowEventFocus(false)
	cam_ff:addChild(quad)
	cam_ff:getOrCreateStateSet():setMode(GLenum.GL_DEPTH_TEST, osg.StateAttribute.OFF)
	cam_ff:getOrCreateStateSet():setMode(GLenum.GL_LIGHTING, osg.StateAttribute.OFF)

	return cam_ff, quad
end

local function setupCameraBloom(cam, resolution, samples, blurPasses)
	cam:setRenderTargetImplementation(osg.Camera.FRAME_BUFFER_OBJECT)
--	cam:setRenderOrder(osg.Camera.PRE_RENDER, 1)
	cam:setName("view_fbo")

	local graphicsContext	= cam:getGraphicsContext()
	local viewport			= cam:getViewport()
	local windowTraits		= graphicsContext:getTraits()

	local w, h = windowTraits:getWidth(), windowTraits:getHeight()
	logger:info("Window size = ", w, "x", h)

	local ws, hs = w*resolution, h*resolution
	viewport:width(ws)
	viewport:height(hs)

	logger:info("Render texture size = ", ws, "x", hs, " (scale factor = ", resolution, ")")

	local GL_RGBA16F, GL_RGB32F = 0x881A, 0x8815
	local texInternalFormat		-- nil => GLenum.GL_RGBA

	local texBase = g.createTexture2D(ws, hs, texInternalFormat)
	local texBright = g.createTexture2D(ws, hs, texInternalFormat)
	cam:attach(osg.Camera.COLOR_BUFFER0, texBase, 0, 0, false, samples, samples)		-- Enable multisamples for base texture
	cam:attach(osg.Camera.COLOR_BUFFER1, texBright)--, 0, 0, false, samples, samples)	-- NOTE: enabling samples for this attachment can help in some cases (GLES as instance)
	cam:getOrCreateStateSet():setAttribute(createBloomBrightnessShaderAttribute())

	-- NOTE: Required 3.4.8 for resize:
	local resizeMask = bit_or(osg.Camera.RESIZE_DEFAULT, osg.Camera.RESIZE_PROJECTIONMATRIX)
	cam:addEventCallback(osgGA.EventHandler(function(event)
		local ea = event:asGUIEventAdapter()
		if ea:getEventType() == osgGA.GUIEventAdapter.RESIZE then
			cam:resize(ea:getWindowWidth()*resolution, ea:getWindowHeight()*resolution, resizeMask)
		end

		return true
	end))

	local E = osg.Matrix.identity()

	-- NOTE:
	-- Create ping-pong FBOs with textures
	-- 1st FBO uses 2nd texture as input
	-- 2nd FBO uses 1st texture as input
	local blurViewport = osg.Viewport(0, 0, 512, 512)			-- TODO: configurable
	logger:info("Blur texture size = ", blurViewport:width(), "x", blurViewport:height())

	local fbo1, texBlur1 = osg.FrameBufferObject(), g.createTexture2D(blurViewport:width(), blurViewport:height(), texInternalFormat)
	fbo1:setAttachment(osg.Camera.COLOR_BUFFER0, osg.FrameBufferAttachment(texBlur1))
	local fbo2, texBlur2 = osg.FrameBufferObject(), g.createTexture2D(blurViewport:width(), blurViewport:height(), texInternalFormat)
	fbo2:setAttachment(osg.Camera.COLOR_BUFFER0, osg.FrameBufferAttachment(texBlur2))

	local blurShaderProgram = createGaussianBlurShaderProgram()

	local function createBlurStateSet(fbo, inputTex, horizontal, renderBin)
		local state = osg.StateSet()
		state:setAttribute(fbo)
		state:setTextureAttributeAndModes(0, inputTex, osg.StateAttribute.PROTECTED)	-- 1st FBO uses 2nd texture as input
		state:addUniform(osg.Uniform.Bool("horizontal", horizontal))
		-- state:setRenderBinDetails(renderBin, "RenderBin", osg.StateSet.PROTECTED_RENDERBIN_DETAILS)

		return state
	end

	-- Front Face camera
	local cam_ff, quad = createCameraFrontFace(graphicsContext, osg.Viewport(0, 0, w, h))

	-- Blur chain
	local blurChain = osg.Group()
	blurChain:getOrCreateStateSet():setAttribute(blurShaderProgram)
	blurChain:getOrCreateStateSet():setAttribute(blurViewport)
	for i = 1, blurPasses or 5 do
		local horizontalBlur = osg.Group()
		local stateSet1 = createBlurStateSet(fbo1, i == 1 and texBright or texBlur2, true, i)
		horizontalBlur:setStateSet(stateSet1)
		horizontalBlur:addChild(quad)

		local verticalBlur = osg.Group()
		local stateSet2 = createBlurStateSet(fbo2, texBlur1, false, i)
		verticalBlur:setStateSet(stateSet2)
		verticalBlur:addChild(quad)

		blurChain:addChild(horizontalBlur)
		blurChain:addChild(verticalBlur)
	end

	cam_ff:insertChild(0, blurChain)
	cam_ff:setProjectionResizePolicy(osg.Camera.FIXED)

	-- Out with bloom
	local camState = cam_ff:getOrCreateStateSet()
	local bloomOutShaderProgram = createBloomOutShaderProgram()
	camState:setTextureAttribute(0, texBase)
	camState:setTextureAttribute(1, texBlur2)
	camState:setAttribute(bloomOutShaderProgram)
--	camState:setDefine("EV_PP_BLOOM_ENABLE_HDR", osg.StateAttribute.ON)
	camState:addUniform(osg.Uniform.Float("exposure", 1.5))

	viewer:addSlave(cam_ff, E, E, false)
end

return
{
	setupCameraBloom = setupCameraBloom
}
