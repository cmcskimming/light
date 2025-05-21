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
--[[
(Client/Server)Interface is a user-facing test interface, respective "VM"s are internal data
]]
do
end
local clients_types = require("@include/clients/types")
local luausignal = require("@light/utils/luau_signal")

type LightClient = clients_types.Identity
type Ok = boolean
type Signal<T...> = luausignal.Identity<T...>

export type Library = typeof(require("@light/lib_main"))

export type ClientInterface = {
	_vm: ClientVM,

	lclient: index<Library, "client">,
	lshared: index<Library, "shared">,
	client: LightClient,

	import: (string) -> any,
}
export type ClientVM = {
	client_id: LightClient,

	connected_server: {
		identity: ServerVM?,
	},
	to_client_signals: {
		connect: Signal<(ServerVM)>,
		disconnect: Signal<(ServerVM)>,
		send_bridge_data: Signal<ServerVM, string, ...any>,
	},
}
export type ClientConstructor = (self: ClientLoader, client_id: number) -> ClientInterface
export type ClientLoader = {
	init: ClientConstructor,
}

export type ServerInterface = {
	_vm: ServerVM,

	lserver: index<Library, "server">,
	lshared: index<Library, "shared">,

	import: (string) -> any,
	connect_client: (self: ServerInterface, ClientInterface) -> (),
	disconnect_client: (self: ServerInterface, ClientInterface) -> (),
}
export type ServerVM = {
	name: string,
	connected_clients: { [LightClient]: ClientVM },
	client_connected: Signal<ClientVM>,
	client_disconnected: Signal<ClientVM>,
	to_server_signals: {
		send_bridge_data: Signal<ClientVM, string, ...any>,
	},
}
export type ServerConstructor = (self: ServerLoader, name: string) -> ServerInterface
export type ServerLoader = {
	init: ServerConstructor,
}

return nil
