local holy = require("@light/holy")
local runtest = require("@runtest/")

type TestInterface = runtest.TestInterface
type Ser = holy.Ser
type Des = holy.Des

local vlq = holy.datatypes.vlq
local metadata = holy._datatype_metadata
local ser = metadata.ser
local des = metadata.des

local spec = runtest.test.spec.init(...)

for size = 2, 8 do
	local datatype = vlq(size)
	local vlqser = ser[datatype]
	local vlqdes = des[datatype]

	local function eqcase(input: number): ()
		local buff = buffer.create(size)
		spec.test(`vlq{size} encode/decode {input}`, function(interface)
			vlqser(buff, 0, input)
			local _, output = vlqdes(buff, 0)
			interface:expect_equal(input, output)
		end)
		spec.test(`vlq{size} no resize {input}`, function(interface)
			local _, new_buff = vlqser(buff, 0, input)
			interface:expect_exactly_equal(buff, new_buff)
		end)
	end

	for testexp = 1, size - 1 do
		local eqcase_start = 128 ^ testexp
		eqcase(eqcase_start)
		eqcase(eqcase_start - 128)
		for sub_exp = 1, testexp - 1 do
			eqcase(eqcase_start + 128 ^ sub_exp)
		end
		local resize_input = 128 ^ testexp
		spec.test(`vlq{size} resizes buff[{testexp}] input {resize_input}`, function(interface): ()
			local buff = buffer.create(testexp)
			local _, new_buff = vlqser(buff, 0, resize_input)
			interface:expect_not_exactly_equal(buff, new_buff)
		end)
		spec.test(`vlq{size} resize -> encode/decode input {resize_input}`, function(interface): ()
			local buff = buffer.create(testexp)
			local _, new_buff = vlqser(buff, 0, resize_input)
			local _, output = vlqdes(new_buff, 0)
			interface:expect_equal(resize_input, output)
		end)
	end
end

return spec.done()
