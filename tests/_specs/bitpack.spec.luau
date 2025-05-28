local bitpack = require("@light/bitpack")
local runtest = require("@runtest/")

type TestInterface = runtest.TestInterface

local spec = runtest.test.spec.init(...)

local packer = bitpack.new()

spec.test("contains_data = false test", function(interface)
	interface:expect_falsy(bitpack.contains_data(packer))
end)

spec.test("contains_data = true test", function(interface)
	bitpack.push(packer, true)
	interface:expect_truthy(bitpack.contains_data(packer))
end)

return spec.done()
