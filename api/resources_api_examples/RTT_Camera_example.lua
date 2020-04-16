-- Example of RTT (Render To Texture) Camera creation.
-- Creates RTT Camera and use ImageReactor with name "image_1" as holder for texture.

local scene	= reactorController:getReactorByName("Scene") -- must be presented in the project
local model	= reactorController:getReactorByName("logo_model") -- must be presented in the project
local holder = reactorController:getReactorByName("image_1") -- must be presented in the project



local Config = {
	TextureWidth	= 500,	-- pixels
	TextureHeight	= 500,	-- pixels
	FovY			= 30,	-- degrees
	Samples			= 2,	-- anti-aliasing level
}

local function createTexture()
	local texture = osg.Texture2D()
	texture:setDataVariance(osg.Object.DYNAMIC)
	texture:setTextureSize(Config.TextureWidth, Config.TextureHeight)
	texture:setInternalFormat(GLenum.GL_RGBA)
	texture:setFilter(osg.Texture.MIN_FILTER, osg.Texture.LINEAR)
	texture:setFilter(osg.Texture.MAG_FILTER, osg.Texture.LINEAR)
	texture:setWrap(osg.Texture.WRAP_S, osg.Texture.CLAMP_TO_EDGE)
	texture:setWrap(osg.Texture.WRAP_T, osg.Texture.CLAMP_TO_EDGE)
	texture:setBorderColor(osg.Vec4(0.0, 0.0, 0.0, 0.0))

	return texture
end

function CreateRttCamera(aName)
	local texture = createTexture()

	local rttCamera = osg.Camera()

	rttCamera:setViewport(0.0, 0.0, Config.TextureWidth, Config.TextureHeight)
	rttCamera:setDrawBuffer(GLenum.GL_BACK)
	rttCamera:setReadBuffer(GLenum.GL_BACK)
	rttCamera:setName(aName)
	rttCamera:setClearColor(osg.Vec4(0.2, 0.5, 1.0, 1.0))--viewer:getCamera():getClearColor())
	rttCamera:setClearMask(bit_or(GLenum.GL_COLOR_BUFFER_BIT, GLenum.GL_DEPTH_BUFFER_BIT))
	rttCamera:setAllowEventFocus(false)
	rttCamera:setRenderOrder(osg.Camera.PRE_RENDER, 0)
	rttCamera:setRenderTargetImplementation(osg.Camera.FRAME_BUFFER_OBJECT)
    rttCamera:setReferenceFrame(osg.Transform.ABSOLUTE_RF)

	rttCamera:attach(osg.Camera.COLOR_BUFFER, texture, 0, 0, false, Config.Samples, Config.Samples)
	rttCamera:asGroup():addChild(model.node)
	rttCamera:setProjectionMatrixAsPerspective(Config.FovY, 1, 0.01, 100)

	holder.image.stateSet:setTextureAttributeAndModes(0, holder.image.texture, osg.StateAttribute.OFF)
	holder.image.stateSet:setTextureAttributeAndModes(0, texture, osg.StateAttribute.ON)
	-- holder.image:_updateTexCoords(osg.Image.BOTTOM_LEFT)	-- osg.Image.BOTTOM_LEFT is default value for ImageReactor

	return rttCamera
end



-- initial object transformation using high-level api
model.trans		= osg.Vec3(0.0, 0.0, -0.3)
model.rotate	= osg.Vec3(0.0, 0.0, 0.0)

-- create and setup camera
local rttCamera = CreateRttCamera("rttCamera")
rttCamera:setViewMatrixAsLookAt(osg.Vec3(0.2, 0.0, 0.0), osg.Vec3(0.0, 0.0, -0.3), osg.Vec3(0.0, 0.1, 0.0))

scene.node:asGroup():addChild(rttCamera)
scene:update()
