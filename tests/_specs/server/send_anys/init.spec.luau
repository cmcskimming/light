local async = require("@test/utils/async")
local light_instance = require("@test/light_instance/main")
local runtest = require("@runtest/")
local task = require("@lune/task")
local timeout = require("@specs/utils/timeout")

type TestInterface = runtest.TestInterface
type Client = typeof(require("@specs/server/send_anys/client"))
type Server = typeof(require("@specs/server/send_anys/server"))

light_instance.init()

local spec = runtest.test.spec.init(...)

local server_vm = light_instance.new_server_vm()
local client_vm = light_instance.new_client_vm()
server_vm:connect_client(client_vm)

spec.test("send anys", function(interface: TestInterface): ()
	local tthread = timeout(interface, 5)

	local server = server_vm.import("@specs/server/send_anys/server") :: Server

	local client = client_vm.import("@specs/server/send_anys/client") :: Client

	async(client.listen, interface)

	async(server.send, client_vm.client)

	async.await()

	task.cancel(tthread)
end)

spec.test("send anys (queued)", function(interface: TestInterface): ()
	local tthread = timeout(interface, 5)

	local server = server_vm.import("@specs/server/send_anys/server") :: Server

	local client = client_vm.import("@specs/server/send_anys/client") :: Client

	async(server.send, client_vm.client)

	async.await()

	async(client.listen, interface)

	async.await()

	task.cancel(tthread)
end)

return spec.done()
