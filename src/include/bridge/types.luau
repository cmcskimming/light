--[[
Generalized server-client networking class.
]]
local client_types = require("../clients/types")

type Client = client_types.Identity

export type ClientCallback<BridgeData...> = (BridgeData...) -> ()
export type ServerCallback<BridgeData...> = (Client, BridgeData...) -> ()

export type Bridge<BridgeData...> = {
	client_event: (ClientCallback<BridgeData...>) -> (),
	fire_server: (BridgeData...) -> (),

	server_event: (ServerCallback<BridgeData...>) -> (),
	fire_all_clients: (BridgeData...) -> (),
	fire_client: (Client, BridgeData...) -> (),
}

return nil
