local runtest = require("@runtest/")

local function meow()
    coroutine.yield()
end

local spec = runtest.test.spec.init(...)

spec.test("fails", function(interface)
    local thread = task.spawn(function() meow() end)
    interface:expect_equal({[coroutine.running()] = thread}, {[thread] = coroutine.running()})
end)

return spec.done()
