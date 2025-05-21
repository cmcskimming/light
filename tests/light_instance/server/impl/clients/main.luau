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
local clients = require("@include/clients/main.h")

local clients_types = require("@include/clients/types")
local luausignal = require("@light/utils/luau_signal")
local server_vm = require("@test/light_instance/server/vm.h").identity

type Client = clients_types.Identity

-- metatable is a slow-path to avoid checking if a player is ingame every time there's a new player
local function __is_connected__index(self: { [Client]: true? }, check_client: Client): true?
	if server_vm.connected_clients[check_client] then
		self[check_client] = true
		return true
	end

	return nil
end
local is_connected = setmetatable({}, { __index = __is_connected__index }) :: { [Client]: true? }
clients.is_connected = is_connected

local client_added_signal = luausignal() :: luausignal.Identity<Client>
local client_removed_signal = luausignal() :: luausignal.Identity<Client>
clients.client_removed = client_removed_signal
clients.client_added = client_added_signal

--[[
TODO: fix any annotations
]]
server_vm.client_connected:connect(function(client): ()
	is_connected[client.client_id] = true
	client_added_signal:fire(client.client_id)
end)
server_vm.client_disconnected:connect(function(client): ()
	is_connected[client.client_id] = nil
	client_removed_signal:fire(client.client_id)
end)

function clients.all_clients(): { Client }
	local output = {}
	local connected = server_vm.connected_clients
	for connected_client in connected do
		table.insert(output, connected_client)
	end
	return output
end

return nil
