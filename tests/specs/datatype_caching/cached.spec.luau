local light_instance = require("@test/light_instance/main")
local runtest = require("@runtest/")

light_instance.init()

local spec = runtest.test.spec.init(...)

local server_vm = light_instance.new_server_vm()

local lshared = server_vm.lshared

local types = lshared.datatypes

spec.test("direct array cache", function(interface)
	local left = types.arr(types.u8)
	local right = types.arr(types.u8)
	interface:expect_exactly_equal(left, right)
end)

spec.test("direct map cache", function(interface)
	local left = types.map(types.u8, types.u16)
	local right = types.map(types.u8, types.u16)
	interface:expect_exactly_equal(left, right)
end)

spec.test("direct struct cache", function(interface)
	local left = types.struct {
		foo = types.u8,
		bar = types.u16,
		baz = types.u24,
	}
	local right = types.struct {
		foo = types.u8,
		bar = types.u16,
		baz = types.u24,
	}
	interface:expect_exactly_equal(left, right)
end)

spec.test("implicit array cache", function(interface)
	local left = types.cached { types.u8 }
	local right = types.cached { types.u8 }
	interface:expect_exactly_equal(left, right)
end)

spec.test("implicit map cache", function(interface)
	local left = types.cached { [types.u8] = types.u16 }
	local right = types.cached { [types.u8] = types.u16 }
	interface:expect_exactly_equal(left, right)
end)

spec.test("implicit struct cache", function(interface)
	local left = types.cached {
		foo = types.u8,
		bar = types.u16,
		baz = types.u24,
	}
	local right = types.cached {
		foo = types.u8,
		bar = types.u16,
		baz = types.u24,
	}
	interface:expect_exactly_equal(left, right)
end)

spec.test("implicit array cache parity", function(interface)
	local left = types.cached { types.u8 }
	local right = types.arr(types.u8)
	interface:expect_exactly_equal(left, right)
end)

spec.test("implicit map cache parity", function(interface)
	local left = types.cached { [types.u8] = types.u16 }
	local right = types.map(types.u8, types.u16)
	interface:expect_exactly_equal(left, right)
end)

spec.test("implicit struct cache parity", function(interface)
	local left = types.cached {
		foo = types.u8,
		bar = types.u16,
		baz = types.u24,
	}
	local right = types.struct {
		foo = types.u8,
		bar = types.u16,
		baz = types.u24,
	}
	interface:expect_exactly_equal(left, right)
end)

spec.test("range cache", function(interface)
	local left = types.range(1, 1273)
	local right = types.range(1, 1273)
	interface:expect_exactly_equal(left, right)
end)

spec.test("clamp cache", function(interface)
	local left = types.clamp(1, 1273)
	local right = types.clamp(1, 1273)
	interface:expect_exactly_equal(left, right)
end)

spec.test("vlq cache", function(interface)
	local t_vlq = types.vlq
	interface:expect_exactly_equal(t_vlq(1), t_vlq(1))
	interface:expect_exactly_equal(t_vlq(2), t_vlq(2))
	interface:expect_exactly_equal(t_vlq(3), t_vlq(3))
	interface:expect_exactly_equal(t_vlq(4), t_vlq(4))
	interface:expect_exactly_equal(t_vlq(5), t_vlq(5))
	interface:expect_exactly_equal(t_vlq(6), t_vlq(6))
	interface:expect_exactly_equal(t_vlq(7), t_vlq(7))
end)

spec.test("str cache", function(interface)
	local left = types.str(types.u48)
	local right = types.str(types.u48)
	interface:expect_exactly_equal(left, right)
end)

spec.test("optional cache", function(interface)
	local left = types.optional(types.u48)
	local right = types.optional(types.u48)
	interface:expect_exactly_equal(left, right)
end)

spec.test("literal cache", function(interface)
	interface:expect_exactly_equal((types.literal(nil)), (types.literal(nil)))
	interface:expect_exactly_equal((types.literal(true)), (types.literal(true)))
	local proxy = newproxy()
	interface:expect_exactly_equal((types.literal(proxy)), (types.literal(proxy)))
end)

spec.test("vect3 cache", function(interface)
	local left = types.vect3(types.u48)
	local right = types.vect3(types.u48)
	interface:expect_exactly_equal(left, right)
end)

spec.test("vect2 cache", function(interface)
	local left = types.vect2(types.u48)
	local right = types.vect2(types.u48)
	interface:expect_exactly_equal(left, right)
end)

spec.test("instances cache", function(interface)
	local left = types.instances.Accessory
	local right = types.instances.Accessory
	interface:expect_exactly_equal(left, right)
end)

spec.test("buffer cache", function(interface)
	local left = types.buff(types.u48)
	local right = types.buff(types.u48)
	interface:expect_exactly_equal(left, right)
end)

return spec.done()
