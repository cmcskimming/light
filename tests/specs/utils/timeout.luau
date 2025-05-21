local runtest = require("@runtest/")
local task = require("@lune/task")

local function timeout(interface: runtest.TestInterface, seconds: number): thread
	local thread = task.delay(seconds, function(): ()
		interface:fail(`\ntimeout after {seconds} seconds`)
		interface:early_end()
	end)

	return thread
end

return timeout
