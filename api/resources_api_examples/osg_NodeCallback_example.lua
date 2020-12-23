-- Example of usage osg.NodeCallback for rotation animation.

local model	= reactorController:getReactorByName("logo_model") -- must be presented in the project

-- initial object transformation using high-level api
model.trans		= osg.Vec3(0.0, 0.0, -0.3)
model.rotate	= osg.Vec3(0.0, 0.0, 0.0)

local period	= 5.0	-- seconds
local step		= 360.0/period

model.node:setUpdateCallback(osg.NodeCallback(function()
	-- Rotate object around 0y axis using high-level api
	model.rotate = osg.Vec3(0.0, timer:getTime() % period * step, 0.0)

	-- Since 3.3 must return bool
	return true
end))

viewer:getCamera():setClearColor(osg.Vec4(163/255.0, 182/255.0, 1.0, 1.0))	-- change clear color for convenience
