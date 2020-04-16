-- Example of osg.Switch usage.
-- Creates RTT Camera and use ImageReactor with name "image_1" as holder for texture.

local hud		= reactorController:getReactorByName("HeadUpDisplay") -- must be presented in the project
local timer		= reactorController:getReactorByName("timer") -- must be presented in the project
local image_1	= reactorController:getReactorByName("image_1") -- must be presented in the project
local image_2	= reactorController:getReactorByName("image_2") -- must be presented in the project
local image_3	= reactorController:getReactorByName("image_3") -- must be presented in the project
local switch	= osg.Switch()

-- image_1:show()
-- image_2:show()
-- image_3:show()

hud:freeze()	-- lock the object to change high-level objects hierarchy
hud:removeChild(image_1)
hud:removeChild(image_2)
hud:removeChild(image_3)
hud:thaw()

-- NOTE: we do not need any freeze/thaw here to change OSG nodes' hierarchy
-- All images are visible on startup
hud.node:addChild(switch)
switch:addChild(image_1.node, true)
switch:addChild(image_2.node, true)
switch:addChild(image_3.node, true)

-- switch:setAllChildrenOff()	-- uncomment to hide all images on startup

local period		= 2.0	--seconds
local currentImage	= 0		-- first image's index is 0

timer:subscribeEvent("onAlarm", function()
	loginfo("Show image_" .. currentImage)
	switch:setSingleChildOn(currentImage)
	currentImage = (currentImage + 1) % 3
end)

timer:start(period, timer.Mode.LOOP)

return switch
