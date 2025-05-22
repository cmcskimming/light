local light = require("@light/lib_main").client
local async = require("@test/utils/async")
local data_a = require("./data_a")
local data_ab = require("./data_ab")
local message_a = require("./message_a")
local message_ab = require("./message_ab")
local runtest = require("@runtest/")
local task = require("@lune/task")

type TestInterface = runtest.TestInterface

local function test_a(interface: TestInterface): ()
	local running = coroutine.running()
	light.connect(message_a, function(incoming): ()
		task.defer(running, incoming)
	end)
	local incoming = coroutine.yield()
	interface:expect_exactly_equal(incoming, data_a)
end

local function test_ab(interface: TestInterface): ()
	local running = coroutine.running()
	light.connect(message_ab, function(incoming): ()
		task.defer(running, incoming)
	end)
	local incoming = coroutine.yield()
	interface:expect_exactly_equal(incoming, data_ab)
end

local client = {}

function client.listen(interface: TestInterface): ()
	async(test_a, interface)
	async(test_ab, interface)
	async.await()
end

return client
