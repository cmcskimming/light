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
local bridge = require("../../include/bridge/main.h")

local bridge_types = require("../../include/bridge/types")
local clients_types = require("../../include/clients/types")
local context = require("../../include/context/main.h")
local report = require("../../report")
local roblox_storage = require("../utils/roblox_storage")

type Client = clients_types.Identity
type Bridge<BridgeData...> = bridge_types.Bridge<BridgeData...>
type ServerCallback<BridgeData...> = bridge_types.ServerCallback<BridgeData...>
type ClientCallback<BridgeData...> = bridge_types.ClientCallback<BridgeData...>

function bridge.new<BridgeData...>(name: string, unreliable: boolean?): Bridge<BridgeData...>
	local remote_event: RemoteEvent
	if context.runcontext == "client" then
		local found_inst = roblox_storage.inst:WaitForChild(name)
		assert(found_inst:IsA("BaseRemoteEvent"))
		remote_event = found_inst :: RemoteEvent
	elseif context.runcontext == "server" then
		remote_event = Instance.new("RemoteEvent")
		remote_event.Name = name
		remote_event.Parent = roblox_storage.inst
	else
		error(`{context.runcontext}`)
	end

	if not remote_event:IsA("BaseRemoteEvent") then
		error(report.problem("remote event inst was not a base remote event"))
	end

	local impl = {} :: Bridge<BridgeData...>

	function impl.server_event(callback: ServerCallback<BridgeData...>): ()
		local connection_function: (...any) -> () = callback
		remote_event.OnServerEvent:Connect(connection_function)
	end

	function impl.client_event(callback: ClientCallback<BridgeData...>): ()
		local connection_function: (...any) -> () = callback
		remote_event.OnClientEvent:Connect(connection_function)
	end

	function impl.fire_server(...: BridgeData...): ()
		remote_event:FireServer(...)
	end

	function impl.fire_all_clients(...: BridgeData...): ()
		remote_event:FireAllClients(...)
	end

	function impl.fire_client(client: Client, ...: BridgeData...): ()
		remote_event:FireClient(client, ...)
	end

	return impl
end

return nil
