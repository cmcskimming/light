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
do
end
local impl_server = require("@test/light_instance/server/implement")

impl_server.init_lune()

local clients_types = require("@include/clients/types")
local interface = require("./interface/main")
local light_instance_types = require("@test/light_instance/types")
local luausignal = require("@light/utils/luau_signal")
local run_service = require("@test/services/run_service/main")
local server_vm_singleton = require("@test/light_instance/server/vm.h")

type ServerConstructor = light_instance_types.ServerConstructor
type ServerLoader = light_instance_types.ServerLoader
type ServerVM = light_instance_types.ServerVM
type ClientVM = light_instance_types.ClientVM
type LightClient = clients_types.Identity

local interface_ctor: ServerConstructor = function(self: ServerLoader, name)
	local client_connected = luausignal()
	local client_disconnected = luausignal()
	local send_bridge_data = luausignal()

	local server_vm: ServerVM = {
		name = name,
		connected_clients = {} :: { [LightClient]: ClientVM },
		client_connected = client_connected,
		client_disconnected = client_disconnected,
		to_server_signals = {
			send_bridge_data = send_bridge_data,
		},
	}
	setmetatable(server_vm, {
		__tostring = function()
			return `Server VM "{name}"`
		end,
	})
	server_vm_singleton.identity = server_vm

	--print(`Initializing {server_vm} instance`)

	impl_server.init_instance()

	local server_interface = interface.new(server_vm)

	setmetatable(server_interface, {
		__tostring = function()
			return `Server Interface "{name}"`
		end,
	})

	run_service.init()

	return server_interface
end

local loader: ServerLoader = {
	init = interface_ctor,
}

return loader
