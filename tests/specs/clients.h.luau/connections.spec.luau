local light_instance = require("@test/light_instance/main")
local runtest = require("@runtest/")

type ClientsH = typeof(require("@include/clients/main.h"))

light_instance.init()

local spec = runtest.test.spec.init(...)

local server_vm = light_instance.new_server_vm()
local client_vm_a = light_instance.new_client_vm()
local client_vm_b = light_instance.new_client_vm()
local client_vm_c = light_instance.new_client_vm()
server_vm:connect_client(client_vm_a)
server_vm:connect_client(client_vm_b)
server_vm:connect_client(client_vm_c)

local clients = server_vm.import("@include/clients/main.h") :: ClientsH

local is_connected = clients.is_connected

spec.test("all clients connected", function(interface): ()
	if not is_connected[client_vm_a.client] then interface:fail("client a should have connected") end
	if not is_connected[client_vm_b.client] then interface:fail("client b should have connected") end
	if not is_connected[client_vm_c.client] then interface:fail("client c should have connected") end
end)

spec.test("disconnecting clients", function(interface): ()
	server_vm:disconnect_client(client_vm_a)
	if is_connected[client_vm_a.client] then interface:fail("client a should have disconnected") end
	server_vm:disconnect_client(client_vm_b)
	if is_connected[client_vm_b.client] then interface:fail("client b should have disconnected") end
	server_vm:disconnect_client(client_vm_c)
	if is_connected[client_vm_c.client] then interface:fail("client c should have disconnected") end
end)

return spec.done()
