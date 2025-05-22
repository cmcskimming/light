local light = require("@light/lib_main").client
local data = require("./data")
local message = require("./message")
local runtest = require("@runtest/")
local task = require("@lune/task")

type TestInterface = runtest.TestInterface

local client = {}

function client.listen(interface: TestInterface): ()
	local running = coroutine.running()
	light.connect(message, function(incoming): ()
		task.defer(running, incoming)
	end)
	local incoming = coroutine.yield()
	interface:expect_equal(incoming, data)
end

return client
