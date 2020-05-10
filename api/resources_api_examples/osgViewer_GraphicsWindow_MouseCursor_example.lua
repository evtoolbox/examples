-- Control cursor appearance on desktop platforms via osgViewer.GraphicsWindow.

-- Get the first (Toolbox's default) window of default global viewer
--		evi.os() returns platform name as string (windows, macos, linux. ios, android or undefined)
--		Cursor will be hidden on desktop platforms
local graphicsWindow = nil
if evi.os() == "macos" or evi.os() == "linux" or evi.os() == "windows" then
	graphicsWindow = viewer:getWindows():at(0)
end

local function enable()
	if graphicsWindow then
		graphicsWindow:setCursor(osgViewer.GraphicsWindow.LeftArrowCursor)
	end
end

local function disable()
	if graphicsWindow then
		graphicsWindow:setCursor(osgViewer.GraphicsWindow.NoCursor)
	end
end

local cursor = {
	enable		= enable,
	disable		= disable,
}

cursor.disable()
-- cursor.enable()

return cursor
