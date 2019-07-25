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

-- EV Toolbox 3.4.0

local logger = set_logger("ev_evi.lua.neuronmocap.server")

function createAndStartServer()
	logger:info("Enabling server to recieve bones info...")
	if not registerPlugin("neuronmocap") then
		logger:error("Cannot enable server without 'neuronmocap' plugin!")
		return
	end
	
	loop	= EVremoted.EventLoop(true)	-- catch exceptions
	server	= EVremoted.Server(loop, CFG_SERVER_PORT)

	echoService = EVremoted.EchoServiceWrapper(function(aRequest --[[, aResponse --]])
		local frameDataMessage		= neuronmocap.FrameDataMessage(aRequest)
		local dataSize				= frameDataMessage:data_size()

--		logger:debug("Recieved data size is ", dataSize)

		for i, bone in ipairs(Bones) do
			logger:trace("Update bone ", bone.name)
			local boneIndex = (i - 1)*6
			bone.data = {	x  = frameDataMessage:data(boneIndex + 0)
						,	y  = frameDataMessage:data(boneIndex + 1)
						,	z  = frameDataMessage:data(boneIndex + 2)
						,	ry = frameDataMessage:data(boneIndex + 3)
						,	rx = frameDataMessage:data(boneIndex + 4)
						,	rz = frameDataMessage:data(boneIndex + 5)
						}
		end
	end)
	echoService:enableDeferredMode()
	server:registerService(echoService)

	server_thread = EVremoted.ThreadedEventLoop(loop)
	server_thread:start()

	local remotedServerFrame = function()
		echoService:process()
	end
	bus:subscribe(remotedServerFrame)

	logger:info("Server enabled!")
end
