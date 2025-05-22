local message = require("./message")
local light = require("@light/lib_main").server
local data = require("./data")
local runtest = require("@runtest/")
local task = require("@lune/task")

type TestInterface = runtest.TestInterface

local function listen(interface: TestInterface): ()
	local running = coroutine.running()
	light.connect(message, function(client, incoming): ()
		task.defer(running, client, incoming)
	end)
	local _, incoming = coroutine.yield()
	interface:expect_exactly_equal(incoming, data)
end

return {
	listen = listen,
}
