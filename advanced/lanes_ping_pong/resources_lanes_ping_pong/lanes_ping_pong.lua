-------------------------------------------------------------------------------
--                                                                           --
-- Copyright 2018 EligoVision. Interactive Technologies                      --
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

-- Ping pong using lanes example

-- EV Toolbox 3.2.0-beta6

l = lanes.linda()

laneGlobals = {
	l = l
}

ping = lanes.gen("*", { globals = laneGlobals, priority = 0 }, function()
    print("Starting thread PING...")
    local _, message = nil, ""
    while message ~= "exit" do
		l:send("ping_message", "ping")
		_, message = l:receive(nil, "pong_message")
		print(message)
    end
end)

pong = lanes.gen("*", { globals = laneGlobals, priority = 0 }, function()
    print("Starting thread PONG...")
    local _, message = nil, ""
    while message ~= "exit" do
		_, message = l:receive(nil, "ping_message")
		print(message)
		l:send("pong_message", "pong")
    end
end)

ping = ping()
pong = pong()

local system = reactorController:getReactorByName("System")
if system then
	system:subscribeEvent("onQuit", function()
		l:send("ping_message", "exit")
		ping = nil

		l:send("pong_message", "exit")
		pong = nil

		collectgarbage()
	end)
end
