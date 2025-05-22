local runtest = require("@runtest/")

local bench = runtest.test.bench.init(..., function()
	return false
end)

local profile_meow_assert = bench.profiler("meowing")

bench.profile("mrrp", function(meow): ()
	profile_meow_assert.open()
	for _ = 1, 100 do
		assert(meow, "TODO")
	end
	profile_meow_assert.close()
end)

return bench.done()
