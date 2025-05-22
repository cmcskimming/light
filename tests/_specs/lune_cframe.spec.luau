local roblox = require("@lune/roblox")
local runtest = require("@runtest/")

local CFrame: typeof(CFrame) = (roblox :: any).CFrame

type TestInterface = runtest.TestInterface

local spec = runtest.test.spec.init(...)

spec.test("CFrame library exists", function(interface: TestInterface)
	interface:expect_truthy(CFrame)
end)

spec.test("identity exists", function(interface: TestInterface)
	interface:expect_truthy(CFrame.identity)
end)

spec.test("identity equivalency", function(interface: TestInterface)
	interface:expect_exactly_equal(CFrame.identity, CFrame.new(0, 0, 0))
end)

spec.test("CF mul CF operator works", function(interface: TestInterface)
	local left = CFrame.new(0, 2, 0)
	local right = CFrame.new(2, 0, 2)

	local result = left * right

	interface:expect_equal(result, CFrame.new(2, 2, 2))
end)

local test_lib_properties: { keyof<typeof(CFrame)> } = {
	"Angles",
	"fromAxisAngle",
	"fromEulerAnglesXYZ",
	"fromEulerAnglesYXZ",
	"fromMatrix",
	"fromOrientation",
	"identity",
	"lookAt",
	"new",
	--[[
	-- these don't exist in lune as of 0.9.3
	]]
	-- "fromEulerAngles",
	-- "fromRotationBetweenVectors",
	-- "lookAlong",
}

for _, property in test_lib_properties do
	spec.test(`CFrame library {property} exists`, function(interface: TestInterface): ()
		-- luau
		interface:expect_truthy((CFrame :: any)[property])
	end)
end

return spec.done()
