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
local impl_client = require("@test/light_instance/client/implement")

impl_client.init_lune()

local client_interface = require("@test/light_instance/client/interface/main")
local client_vm_singleton = require("@test/light_instance/client/vm.h")
local connected_server = require("@test/light_instance/client/connected_server")
local light_instance_types = require("@test/light_instance/types")
local luausignal = require("@light/utils/luau_signal")
local run_service = require("@test/services/run_service/main")

type Signal<T...> = luausignal.Identity<T...>
type ClientVM = light_instance_types.ClientVM
type ClientLoader = light_instance_types.ClientLoader
type ClientInterface = light_instance_types.ClientInterface
type ClientVMConstructor = light_instance_types.ClientConstructor
type ServerVM = light_instance_types.ServerVM

local initialized = false
local interface_ctor: ClientVMConstructor = function(self: ClientLoader, client_id: number)
	if initialized then error("already initialized this VM") end
	initialized = true

	local connect_client = luausignal() :: Signal<ServerVM>
	local disconnect_client = luausignal() :: Signal<ServerVM>
	local send_bridge_data = luausignal() :: Signal<ServerVM, string, ...any>

	local client_vm: ClientVM = {
		client_id = client_id :: any,
		connected_server = connected_server,
		to_client_signals = {
			connect = connect_client,
			disconnect = disconnect_client,
			send_bridge_data = send_bridge_data,
		},
	}
	setmetatable(client_vm, {
		__tostring = function()
			return `Client VM {client_id}`
		end,
	})
	client_vm_singleton.identity = client_vm

	connect_client:connect(function(server): ()
		--print(`{client_vm} connecting to server "{server.name}"`)
		connected_server.identity = server
	end)

	disconnect_client:connect(function(server): ()
		local currently_connected = client_vm.connected_server.identity
		if not currently_connected then
			error(
				`tried to disconnect {client_vm} from server`
					.. ` "{server.name}", but the client is not connected to a server`
			)
		end
		if currently_connected ~= server then
			error(
				`tried to disconnect {client_vm} from server`
					.. ` "{server.name}", but the client is currently connected to "{currently_connected.name}"`
			)
		end
		--print(`{client_vm} disconnecting from server "{server.name}"`)
		connected_server.identity = nil
	end)

	--print(`Initializing {client_vm} instance`)

	impl_client.init_instance()

	local interface = client_interface.new(client_vm)
	setmetatable(interface, {
		__tostring = function()
			return `Client Interface {client_id}`
		end,
	})

	run_service.init()

	return interface
end

local loader: ClientLoader = {
	init = interface_ctor,
}

return loader
