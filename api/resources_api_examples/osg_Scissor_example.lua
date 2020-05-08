-- Example of osg.Scissor usage.
-- Create scissor and show cropped foreground by 800x300 pixels.
-- Cropped visible area is in left bottom corner of screen.

local foreground	= reactorController:getReactorByName("white_rect") -- must be presented in the project
local scissor		= osg.Scissor()

-- move foreground on top using high-level api
foreground.layer = 0.9

-- crop area with size 800x300 pixels from (100, 100) pixels left bottom corner
scissor:setScissor(100, 100, 800, 300)
foreground.node:getOrCreateStateSet():setAttributeAndModes(scissor, osg.StateAttribute.ON)

return scissor
