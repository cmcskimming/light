--[[MIT License Copyright (c) 2025 @hardlyardi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]
--[[
--FOR DESCRIPTIONS OF API & CODE FUNCTION, ETC: https://light.ardi.gg/
--FOR ISSUES, BUG REPORTS, OR FEATURE REQUESTS: https://light.ardi.gg/github
--ROBLOX OSS SERVER: https://discord.com/invite/5KjV64PA3d
--MY DISCORD (please only contact for important questions): https://discord.com/users/331399684415553538/
]]
local lib_client = require("./lib_client.h")

local begin_replication = require("./api_client/begin_replication/main")
local holy = require("./holy")
local messages = require("./messages/client")
local process_incoming_reliable = require("./process_incoming/client/reliable")
local process_incoming_unreliable = require("./process_incoming/client/unreliable")
local send = require("./api_client/send/main")
local send_unreliably = require("./api_client/send_unreliably/main")
local step_replication = require("./api_client/step_replication/main")

local function init(): ()
	process_incoming_reliable.init()
	process_incoming_unreliable.init()
end

lib_client.stfu = holy.stfu

lib_client.send = send
lib_client.send_unreliably = send_unreliably

lib_client.connect = messages.async_connect
lib_client.connect_sync = messages.sync_connect
lib_client.disconnect = messages.disconnect

lib_client.step_replication = step_replication
lib_client.begin_replication = begin_replication

return init
