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

local ANIMATION_TIME = 0.2

Label = class("Label")
	:field("reactor")
	:field("pat")

	:compositefield("_impl")
		:field("startTime")
		:field("mode")
		:field("duration")
		:field("callback")
	:done()
:done()

Label.Mode = defineEnum {
	HIDE	= "hide",
	SHOW	= "show",
}

function Label:_construct(aReactor)
	self.reactor = aReactor
	self.pat = osg.PositionAttitudeTransform()
	EVosgUtil.insertNode(self.pat:asGroup(), self.reactor.node)
	self.pat:setName("pat_" .. self.reactor.name .. "_rb_50")

	self._impl.duration = ANIMATION_TIME
	self._impl.callback = osg.NodeCallback(function()
		local currentTime = timer:getTime()
		local scale = math.max(math.min((currentTime - self._impl.startTime)/self._impl.duration, 1.0), 0.0)
		local value = self._impl.mode == Label.Mode.HIDE and 1.0 - scale or scale
		self.pat:setScale(osg.Vec3(value, 1.0, value))

		if scale == 1.0 then
			local value = self._impl.mode == Label.Mode.HIDE and 0.0 or 1.0
			self.pat:setScale(osg.Vec3(value, 1.0, value))
			self.reactor:show(value == 1.0)

			self.pat:setUpdateCallback(nil)
		end

		return true
	end)

	self.pat:setScale(osg.Vec3(0.0, 1.0, 0.0))
	self.pat:setPosition(self.reactor.trans)
	self.reactor:hide()
end

function Label:show()
	self:hide(false)
end

function Label:hide(aDoHide)
	local aDoHide		= aDoHide == nil or aDoHide
	local mode			= aDoHide and Label.Mode.HIDE or Label.Mode.SHOW
	local isVisible		= self.pat:getScale():x() == 1.0
	local currentTime	= timer:getTime()

	if self.reactor.node:getUpdateCallback() then
		if self._impl.mode == mode then return end

		self._impl.startTime = currentTime - (self._impl.duration - (currentTime - self._impl.startTime))
		self._impl.mode = mode
	elseif aDoHide == isVisible then
		self._impl.startTime = currentTime
		self._impl.mode = mode

		local value = aDoHide and 1.0 or 0.0
		self.pat:setScale(osg.Vec3(value, 1.0, value))

		if self.pat:getUpdateCallback() then
			logerror("Label callback has been already set!")
		end

		self.reactor:show()
		self.pat:setUpdateCallback(self._impl.callback)
	end
end

function Label:setAnimationDuration(aDuration)
	self._impl.duration = aDuration
end

function Label:reset()
	self:hide()
end



-- Text object
local reactor = reactorController:getReactorByName("object/text")
local text = reactorController:getReactorByName("scale/text")
if reactor and text then
	loginfo("Create label with animation for", reactorName)
	local label = Label(text)
	label:show()

	reactor:subscribeEvent("onAnimationStart", function() label:hide() end)
	reactor:subscribeEvent("onAnimationFinished", function() label:show() end)
end

-- Model object
local reactor = reactorController:getReactorByName("object/model")
local text = reactorController:getReactorByName("scale/model")
if reactor and text then
	loginfo("Create label with animation for model")
	local label = Label(text)
	label:show()

	reactor:subscribeEvent("onAnimationStart", function() label:hide() end)
	reactor:subscribeEvent("onAnimationFinished", function() label:show() end)
end

-- Timer object
local reactor = reactorController:getReactorByName("object/timer")
local text = reactorController:getReactorByName("scale/timer")
if reactor and text then
	loginfo("Create label with animation for timer")
	local label = Label(text)
	label:show()

	reactor:subscribeEvent("onAnimationStart", function() label:hide() end)
	reactor:subscribeEvent("onAnimationFinished", function() label:show() end)
end

-- Audio object
local reactor = reactorController:getReactorByName("object/audio")
local text = reactorController:getReactorByName("scale/audio")
if reactor and text then
	loginfo("Create label with animation for audio")
	local label = Label(text)
	label:show()

	reactor:subscribeEvent("onAnimationStart", function() label:hide() end)
	reactor:subscribeEvent("onAnimationFinished", function() label:show() end)
end

-- Image object
local reactor = reactorController:getReactorByName("object/image")
local text = reactorController:getReactorByName("scale/image")
if reactor and text then
	loginfo("Create label with animation for image")
	local label = Label(text)
	label:show()

	reactor:subscribeEvent("onAnimationStart", function() label:hide() end)
	reactor:subscribeEvent("onAnimationFinished", function() label:show() end)
end
