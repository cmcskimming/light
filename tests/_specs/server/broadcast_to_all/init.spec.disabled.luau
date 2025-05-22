local async = require("@test/utils/async")
local light_instance = require("@test/light_instance/main")
local runtest = require("@runtest/")
local task = require("@lune/task")
local timeout = require("@specs/utils/timeout")

type TestInterface = runtest.TestInterface
type Client = typeof(require("@specs/server/broadcast_to_all/client"))
type Server = typeof(require("@specs/server/broadcast_to_all/server"))

light_instance.init()

local spec = runtest.test.spec.init(...)

local server_vm = light_instance.new_server_vm()

local client_vms = {}

for i = 1, 2 do
	local vm = light_instance.new_client_vm()
	server_vm:connect_client(vm)
	table.insert(client_vms, vm)
end

spec.test("broadcast to all", function(interface: TestInterface): ()
	local tthread = timeout(interface, 5)

	local server = server_vm.import("@specs/server/broadcast_to_all/server") :: Server

	for _, client_vm in client_vms do
		local client_script = client_vm.import("@specs/server/broadcast_to_all/client") :: Client
		async(client_script.listen, interface)
	end

	async(server.broadcast_all)

	async.await()

	task.cancel(tthread)
end)

spec.test("broadcast to all (queued)", function(interface: TestInterface): ()
	local tthread = timeout(interface, 5)

	local server = server_vm.import("@specs/server/broadcast_to_all/server") :: Server

	async(server.broadcast_all)

	async.await()

	for _, client_vm in client_vms do
		local client_script = client_vm.import("@specs/server/broadcast_to_all/client") :: Client
		async(client_script.listen, interface)
	end

	async.await()

	task.cancel(tthread)
end)

return spec.done()
