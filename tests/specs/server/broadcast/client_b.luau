local light = require("@light/lib_main").client
local async = require("@test/utils/async")
local data_ab = require("./data_ab")
local data_b = require("./data_b")
local message_ab = require("./message_ab")
local message_b = require("./message_b")
local runtest = require("@runtest/")
local task = require("@lune/task")

type TestInterface = runtest.TestInterface

local function test_b(interface: TestInterface): ()
	local running = coroutine.running()
	light.connect(message_b, function(incoming): ()
		task.defer(running, incoming)
	end)
	local incoming = coroutine.yield()
	interface:expect_exactly_equal(incoming, data_b)
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
	async(test_b, interface)
	async(test_ab, interface)
	async.await()
end

return client
