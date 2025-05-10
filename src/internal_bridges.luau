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
local bridge = require("./include/bridge/main.h")
local bridge_types = require("./include/bridge/types")
local light_types = require("./types")

type MessagingBridgeData = light_types.MessagingBridgeData
type Bridge<BridgeData...> = bridge_types.Bridge<BridgeData...>

return {
	to_client = {
		reliable_messaging = bridge.new("TO_CLIENT_RELIABLE") :: Bridge<...MessagingBridgeData>,
		unreliable_messaging = bridge.new("TO_CLIENT_UNRELIABLE") :: Bridge<MessagingBridgeData, buffer?>,
		sync_one_id = bridge.new("TO_CLIENT_SYNC_ONE") :: Bridge<buffer>,
		sync_many_ids = bridge.new("TO_CLIENT_SYNC_MANY") :: Bridge<buffer>,
	},
	to_server = {
		reliable_messaging = bridge.new("TO_SERVER_RELIABLE") :: Bridge<MessagingBridgeData, buffer?>,
		unreliable_messaging = bridge.new("TO_SERVER_UNRELIABLE") :: Bridge<MessagingBridgeData, buffer?>,
	},
}
