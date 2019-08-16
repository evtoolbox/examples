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

-- EV Toolbox 3.2.0-rc4

require "utf8.lua"

local textField = {
	container	= reactorController:getReactorByName("TextFieldContainer")
,	input		= reactorController:getReactorByName("TextFieldInput")
,	active		= false
}

local function activate()
	if textField.active then
		return
	end

	textField.container.rect.color = osg.Vec4(0.0, 0.5, 0.5, 1.0)
	textField.active = true
	loginfo("text input activated")
end

local function disactivate()
	if not textField.active then
		return
	end

	textField.container.rect.color = osg.Vec4(0.0, 0.0, 0.0, 1.0)
	textField.active = false
	loginfo("text input disactivated")
end


-- Key down processing
local guiEventHandler = osgGA.GUIEventHandler(function(eventAdapter, actionAdapter)
		if not textField.active or eventAdapter:getEventType() ~= osgGA.GUIEventAdapter.KEYDOWN then
			return false	-- do not stop process
		end

		-- Process only keydown events + TextField must be active

		local key = eventAdapter:getKey()

		if key == bit_or(osgGA.GUIEventAdapter.KEY_Return) then
			disactivate()
			return true;
		end

		if key == bit_or(osgGA.GUIEventAdapter.KEY_BackSpace) then
			local value = textField.input.text.value
			local length = utf8.len(value)
			if length > 0 then
				textField.input.text.value = utf8.sub(value, 0, length - 1)
			end

			return false
		end

		-- http://www.fileformat.info/info/charset/UTF-8/list.htm
		if key < 0x20 or key > 0x7e then
			-- Only english letters + some specials
			return false
		end

		local char = utf8.char(key)
		local caps = bit_and(eventAdapter:getModKeyMask(), osgGA.GUIEventAdapter.MODKEY_CAPS_LOCK) ~= 0
		local shift = bit_and(eventAdapter:getModKeyMask(), bit_or(osgGA.GUIEventAdapter.MODKEY_LEFT_SHIFT,
																   osgGA.GUIEventAdapter.MODKEY_RIGHT_SHIFT)) ~= 0
		if (caps and not shift) or (shift and not caps) then
			char = string.upper(char)
		end


		loginfo("text input adding char: " .. char)

		textField.input.text.value = textField.input.text.value .. char

		return false	-- do not stop process
end)
viewer:addEventHandler(guiEventHandler)


-- Activation/deactivation on mouse down

-- NOTE: GUICanvas must be presented (at least on 3.2.0-rc3)
local pickHandlerObserver = EVosgGA.PickHandler.Observer()
pickHandlerObserver:setOnDownCb(function(nodePath)
	for i = nodePath:size() - 1, 0, -1 do
		local nodeName = nodePath:at(i):name()
		if nodeName == textField.container.id then
			activate()
			return true		-- stop process
		end
	end

	disactivate()

	return false	-- do not stop process
end)

pickHandler:registerObserver(pickHandlerObserver)
