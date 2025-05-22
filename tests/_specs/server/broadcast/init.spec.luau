local async = require("@test/utils/async")
local light_instance = require("@test/light_instance/main")
local runtest = require("@runtest/")
local task = require("@lune/task")
local timeout = require("@specs/utils/timeout")

type TestInterface = runtest.TestInterface
type ClientA = typeof(require("@specs/server/broadcast/client_a"))
type ClientB = typeof(require("@specs/server/broadcast/client_b"))
type Server = typeof(require("@specs/server/broadcast/server"))

light_instance.init()

local spec = runtest.test.spec.init(...)

local server_vm = light_instance.new_server_vm()
local client_vm_a = light_instance.new_client_vm()
local client_vm_b = light_instance.new_client_vm()
server_vm:connect_client(client_vm_a)
server_vm:connect_client(client_vm_b)

spec.test("broadcast", function(interface: TestInterface): ()
	local tthread = timeout(interface, 5)

	local server = server_vm.import("@specs/server/broadcast/server") :: Server

	local client_a = client_vm_a.import("@specs/server/broadcast/client_a") :: ClientA
	local client_b = client_vm_b.import("@specs/server/broadcast/client_b") :: ClientB

	async(client_a.listen, interface)
	async(client_b.listen, interface)
	async(server.broadcast, client_vm_a.client, client_vm_b.client)

	async.await()

	task.cancel(tthread)
end)

spec.test("broadcast (queued)", function(interface: TestInterface): ()
	local tthread = timeout(interface, 5)

	local server = server_vm.import("@specs/server/broadcast/server") :: Server

	local client_a = client_vm_a.import("@specs/server/broadcast/client_a") :: ClientA
	local client_b = client_vm_b.import("@specs/server/broadcast/client_b") :: ClientB

	async(server.broadcast, client_vm_a.client, client_vm_b.client)

	task.wait()

	async(client_a.listen, interface)
	async(client_b.listen, interface)

	async.await()

	task.cancel(tthread)
end)

return spec.done()
