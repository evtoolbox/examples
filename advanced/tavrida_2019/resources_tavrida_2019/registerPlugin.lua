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

local logger = set_logger("ev_evi.lua.neuronmocap.registerPlugins")

local pluginManager = evi.PluginManager.instance()
function registerPlugin(aPluginName)
	logger:info("Registering plugin .. '" .. aPluginName .. "'")
	if not pluginManager then
		logger:critical("Cannot create plugin manager!")
		
		return
	end

	if pluginManager:registerPlugin(aPluginName) < 0 then
		logger:error("Cannot register `" .. aPluginName .."' plugin!")
	
		return
	end
	
	local logMsg =	"+---------------------------------------------------+\n"
				..	"   '".. aPluginName .. "' plugin registered          \n"
				..	"+---------------------------------------------------+\n"
	logger:info("\n" .. logMsg)

	return true
end

--neuronmocap.FrameDataMessage