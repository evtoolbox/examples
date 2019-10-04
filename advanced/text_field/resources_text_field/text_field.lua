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

local utf8 = require("utf8.lua")

local textField = {
	container	= reactorController:getReactorByName("TextFieldContainer")
,	input		= reactorController:getReactorByName("TextFieldInput")
,	active		= false
}

local system = reactorController:getReactorByName("System")

local function activate()
	if textField.active then
		return
	end

	textField.container.rect.color = osg.Vec4(0.0, 0.5, 0.5, 1.0)
	textField.active = true

	if system and evi.os() == "android" or evi.os() == "ios" then
		system:showVirtualKeyboard()
	end

	loginfo("text input activated")
end

local function disactivate()
	if not textField.active then
		return
	end

	textField.container.rect.color = osg.Vec4(0.0, 0.0, 0.0, 1.0)
	textField.active = false

	if system and evi.os() == "android" or evi.os() == "ios" then
		system:hideVirtualKeyboard()
	end

	loginfo("text input disactivated")
end


local nonPrintableKeys = {
		osgGA.GUIEventAdapter.KEY_BackSpace
	,	osgGA.GUIEventAdapter.KEY_Tab
	,	osgGA.GUIEventAdapter.KEY_Linefeed
	,	osgGA.GUIEventAdapter.KEY_Clear
	,	osgGA.GUIEventAdapter.KEY_Return
	,	osgGA.GUIEventAdapter.KEY_Pause
	,	osgGA.GUIEventAdapter.KEY_Scroll_Lock
	,	osgGA.GUIEventAdapter.KEY_Sys_Req
	,	osgGA.GUIEventAdapter.KEY_Escape
	,	osgGA.GUIEventAdapter.KEY_Delete
	,	osgGA.GUIEventAdapter.KEY_Home
	,	osgGA.GUIEventAdapter.KEY_Left
	,	osgGA.GUIEventAdapter.KEY_Up
	,	osgGA.GUIEventAdapter.KEY_Right
	,	osgGA.GUIEventAdapter.KEY_Down
	,	osgGA.GUIEventAdapter.KEY_Prior
	,	osgGA.GUIEventAdapter.KEY_Page_Up
	,	osgGA.GUIEventAdapter.KEY_Next
	,	osgGA.GUIEventAdapter.KEY_Page_Down
	,	osgGA.GUIEventAdapter.KEY_End
	,	osgGA.GUIEventAdapter.KEY_Begin
	,	osgGA.GUIEventAdapter.KEY_Select
	,	osgGA.GUIEventAdapter.KEY_Print
	,	osgGA.GUIEventAdapter.KEY_Execute
	,	osgGA.GUIEventAdapter.KEY_Insert
	,	osgGA.GUIEventAdapter.KEY_Undo
	,	osgGA.GUIEventAdapter.KEY_Redo
	,	osgGA.GUIEventAdapter.KEY_Menu
	,	osgGA.GUIEventAdapter.KEY_Find
	,	osgGA.GUIEventAdapter.KEY_Cancel
	,	osgGA.GUIEventAdapter.KEY_Help
	,	osgGA.GUIEventAdapter.KEY_Break
	,	osgGA.GUIEventAdapter.KEY_Mode_switch
	,	osgGA.GUIEventAdapter.KEY_Script_switch
	,	osgGA.GUIEventAdapter.KEY_Num_Lock
	,	osgGA.GUIEventAdapter.KEY_KP_Space
	,	osgGA.GUIEventAdapter.KEY_KP_Tab
	,	osgGA.GUIEventAdapter.KEY_KP_Enter
	,	osgGA.GUIEventAdapter.KEY_KP_F1
	,	osgGA.GUIEventAdapter.KEY_KP_F2
	,	osgGA.GUIEventAdapter.KEY_KP_F3
	,	osgGA.GUIEventAdapter.KEY_KP_F4
	,	osgGA.GUIEventAdapter.KEY_KP_Home
	,	osgGA.GUIEventAdapter.KEY_KP_Left
	,	osgGA.GUIEventAdapter.KEY_KP_Up
	,	osgGA.GUIEventAdapter.KEY_KP_Right
	,	osgGA.GUIEventAdapter.KEY_KP_Down
	,	osgGA.GUIEventAdapter.KEY_KP_Prior
	,	osgGA.GUIEventAdapter.KEY_KP_Page_Up
	,	osgGA.GUIEventAdapter.KEY_KP_Next
	,	osgGA.GUIEventAdapter.KEY_KP_Page_Down
	,	osgGA.GUIEventAdapter.KEY_KP_End
	,	osgGA.GUIEventAdapter.KEY_KP_Begin
	,	osgGA.GUIEventAdapter.KEY_KP_Insert
	,	osgGA.GUIEventAdapter.KEY_KP_Delete
	-- KP
	,	osgGA.GUIEventAdapter.KEY_F1
	,	osgGA.GUIEventAdapter.KEY_F2
	,	osgGA.GUIEventAdapter.KEY_F3
	,	osgGA.GUIEventAdapter.KEY_F4
	,	osgGA.GUIEventAdapter.KEY_F5
	,	osgGA.GUIEventAdapter.KEY_F6
	,	osgGA.GUIEventAdapter.KEY_F7
	,	osgGA.GUIEventAdapter.KEY_F8
	,	osgGA.GUIEventAdapter.KEY_F9
	,	osgGA.GUIEventAdapter.KEY_F10
	,	osgGA.GUIEventAdapter.KEY_F11
	,	osgGA.GUIEventAdapter.KEY_F12
	,	osgGA.GUIEventAdapter.KEY_F13
	,	osgGA.GUIEventAdapter.KEY_F14
	,	osgGA.GUIEventAdapter.KEY_F15
	,	osgGA.GUIEventAdapter.KEY_F16
	,	osgGA.GUIEventAdapter.KEY_F17
	,	osgGA.GUIEventAdapter.KEY_F18
	,	osgGA.GUIEventAdapter.KEY_F19
	,	osgGA.GUIEventAdapter.KEY_F20
	,	osgGA.GUIEventAdapter.KEY_F21
	,	osgGA.GUIEventAdapter.KEY_F22
	,	osgGA.GUIEventAdapter.KEY_F23
	,	osgGA.GUIEventAdapter.KEY_F24
	,	osgGA.GUIEventAdapter.KEY_F25
	,	osgGA.GUIEventAdapter.KEY_F26
	,	osgGA.GUIEventAdapter.KEY_F27
	,	osgGA.GUIEventAdapter.KEY_F28
	,	osgGA.GUIEventAdapter.KEY_F29
	,	osgGA.GUIEventAdapter.KEY_F30
	,	osgGA.GUIEventAdapter.KEY_F31
	,	osgGA.GUIEventAdapter.KEY_F32
	,	osgGA.GUIEventAdapter.KEY_F33
	,	osgGA.GUIEventAdapter.KEY_F34
	,	osgGA.GUIEventAdapter.KEY_F35
	,	osgGA.GUIEventAdapter.KEY_Shift_L
	,	osgGA.GUIEventAdapter.KEY_Shift_R
	,	osgGA.GUIEventAdapter.KEY_Control_L
	,	osgGA.GUIEventAdapter.KEY_Control_R
	,	osgGA.GUIEventAdapter.KEY_Caps_Lock
	,	osgGA.GUIEventAdapter.KEY_Shift_Lock
	,	osgGA.GUIEventAdapter.KEY_Meta_L
	,	osgGA.GUIEventAdapter.KEY_Meta_R
	,	osgGA.GUIEventAdapter.KEY_Alt_L
	,	osgGA.GUIEventAdapter.KEY_Alt_R
	,	osgGA.GUIEventAdapter.KEY_Super_L
	,	osgGA.GUIEventAdapter.KEY_Super_R
	,	osgGA.GUIEventAdapter.KEY_Hyper_L
	,	osgGA.GUIEventAdapter.KEY_Hyper_R
}

local numPadKeys = {}
numPadKeys[bit_or(osgGA.GUIEventAdapter.KEY_KP_Equal)]		= '='
numPadKeys[bit_or(osgGA.GUIEventAdapter.KEY_KP_Multiply)]	= '*'
numPadKeys[bit_or(osgGA.GUIEventAdapter.KEY_KP_Add)]		= '+'
numPadKeys[bit_or(osgGA.GUIEventAdapter.KEY_KP_Separator)]	= '.'
numPadKeys[bit_or(osgGA.GUIEventAdapter.KEY_KP_Subtract)]	= '-'
numPadKeys[bit_or(osgGA.GUIEventAdapter.KEY_KP_Decimal)]	= '.'
numPadKeys[bit_or(osgGA.GUIEventAdapter.KEY_KP_Divide)]		= '/'
numPadKeys[bit_or(osgGA.GUIEventAdapter.KEY_KP_0)]			= '0'
numPadKeys[bit_or(osgGA.GUIEventAdapter.KEY_KP_1)]			= '1'
numPadKeys[bit_or(osgGA.GUIEventAdapter.KEY_KP_2)]			= '2'
numPadKeys[bit_or(osgGA.GUIEventAdapter.KEY_KP_3)]			= '3'
numPadKeys[bit_or(osgGA.GUIEventAdapter.KEY_KP_4)]			= '4'
numPadKeys[bit_or(osgGA.GUIEventAdapter.KEY_KP_5)]			= '5'
numPadKeys[bit_or(osgGA.GUIEventAdapter.KEY_KP_6)]			= '6'
numPadKeys[bit_or(osgGA.GUIEventAdapter.KEY_KP_7)]			= '7'
numPadKeys[bit_or(osgGA.GUIEventAdapter.KEY_KP_8)]			= '8'
numPadKeys[bit_or(osgGA.GUIEventAdapter.KEY_KP_9)]			= '9'


-- Key down processing
local guiEventHandler = osgGA.GUIEventHandler(function(eventAdapter, actionAdapter)
		if not textField.active or eventAdapter:getEventType() ~= osgGA.GUIEventAdapter.KEYDOWN then
			return false	-- do not stop process
		end

		-- Process only keydown events + TextField must be active

		local key = eventAdapter:getKey()

		if key == bit_or(osgGA.GUIEventAdapter.KEY_Return) or key == bit_or(osgGA.GUIEventAdapter.KEY_KP_Enter) then
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

		-- other "non-printable" keys (function keys)
		for _,v in pairs(nonPrintableKeys) do
			if key == bit_or(v) then
				return false
			end
		end

		-- disable "complicated input" behavior
		if bit_and(eventAdapter:getModKeyMask(), bit_or(osgGA.GUIEventAdapter.MODKEY_LEFT_CTRL,
														osgGA.GUIEventAdapter.MODKEY_RIGHT_CTRL,
														osgGA.GUIEventAdapter.MODKEY_LEFT_ALT,
														osgGA.GUIEventAdapter.MODKEY_RIGHT_ALT,
														osgGA.GUIEventAdapter.MODKEY_SUPER)) ~= 0 then
			return false
		end


		for k,v in pairs(numPadKeys) do
			if key == k then
				loginfo("TextField: add char (numpad): " .. v)
				textField.input.text.value = textField.input.text.value .. v

				return false	-- do not stop process
			end
		end

		local char = utf8.char(key)
		--[[
		local caps = bit_and(eventAdapter:getModKeyMask(), osgGA.GUIEventAdapter.MODKEY_CAPS_LOCK) ~= 0
		local shift = bit_and(eventAdapter:getModKeyMask(), bit_or(osgGA.GUIEventAdapter.MODKEY_LEFT_SHIFT,
																   osgGA.GUIEventAdapter.MODKEY_RIGHT_SHIFT)) ~= 0
		if (caps and not shift) or (shift and not caps) then
			char = string.upper(char)
		end
		--]]

		loginfo("TextField: add char: " .. char)
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
