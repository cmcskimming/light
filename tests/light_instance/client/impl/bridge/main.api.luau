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
local bridge = require("@include/bridge/main.h")

local bridge_types = require("@include/bridge/types")
local client_vm = require("@test/light_instance/client/vm.h").identity
local clients_types = require("@include/clients/types")
local connected_server = require("@test/light_instance/client/connected_server")
local luausignal = require("@light/utils/luau_signal")
local recursively_nil_nulls = require("@test/light_instance/recursively_nil_nulls")

type Bridge<BridgeData...> = bridge_types.Bridge<BridgeData...>
type Client = clients_types.Identity
type ClientCallback<BridgeData...> = bridge_types.ClientCallback<BridgeData...>
type ServerCallback<BridgeData...> = bridge_types.ServerCallback<BridgeData...>
type Signal<T...> = luausignal.Identity<T...>

local bridge_signals = {} :: { [string]: Signal<...any> }

client_vm.to_client_signals.send_bridge_data:connect(function(server, bridge_name, ...): ()
	local connected = connected_server.identity
	if connected == nil then
		error(
			`{server} tried to send a message to {client_vm}, `
				.. `but the client was not connected to any server.`
		)
	elseif connected ~= server then
		error(
			`{server} tried to send a message to {client_vm}, `
				.. `but the client is already connected to "{connected}"`
		)
	end

	local bridge_signal = bridge_signals[bridge_name]
	if bridge_signal == nil then
		error(`bridge with name {bridge_name} does not exist, dropping message`)
	end

	local data_table = { ... }

	recursively_nil_nulls(data_table)

	bridge_signal:fire(table.unpack(data_table))
end)

function bridge.new<BridgeData...>(name: string, unreliable: boolean?): Bridge<BridgeData...>
	local existing_signal = bridge_signals[name]
	if existing_signal then error(`signal already exists under name {name}`) end

	local bridge_signal = luausignal() :: Signal<BridgeData...>
	bridge_signals[name] = bridge_signal

	local impl = {} :: Bridge<BridgeData...>

	function impl.client_event(callback: ClientCallback<BridgeData...>): ()
		local connection_function: (...any) -> () = callback
		bridge_signal:connect(connection_function)
	end

	function impl.fire_server(...: BridgeData...): ()
		local connected = connected_server.identity

		if connected == nil then
			warn("tried to fire bridge to server while not connected to any server")
			return
		end

		-- Luau
		(connected :: any).to_server_signals.send_bridge_data:fire(client_vm, name, ...)
	end

	return impl
end

return nil
