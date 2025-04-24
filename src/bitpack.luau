local U32_BYTES = 4

local holy = require("./holy")

local metadata = holy._datatype_metadata
local uint_size = holy.uint_size
local vlq_size = holy.vlq_size

local lookup_uint_ser_static = holy.const_lookups.uint.ser_static

type u32 = number
type u8 = number
type u16 = number
type u24 = number

export type Packer = {
	array: { u32 },
	current: u8 | u16 | u24 | u32,
	increment: u32,
}

export type Unpacker = {
	array: { boolean },
	pos: number,
}

type function negate(T: type): type
	return types.negationof(T)
end

local vlq2 = holy.datatypes.vlq(2)
local ser_vlq2 = metadata.ser[vlq2]
local des_vlq2 = metadata.des[vlq2]

--[=[
Construct a new bitpacker.
]=]
local function packer(): Packer
	return {
		array = {} :: { u32 },
		current = 0 :: u32,
		increment = 1 :: u32,
	}
end

--[=[
Reset a bitpacker's bit array, current progress, and increment, so it can be reused.
]=]
local function reset(packer: Packer): ()
	packer.array = {} :: { u32 }
	packer.current = 0 :: u32
	packer.increment = 1 :: u32
end

--[=[
Push false to the most significant bit.
]=]
@native
local function push_false(packer: Packer): ()
	local increment = packer.increment

	if increment < 2 ^ 32 then
		packer.increment = increment * 0b10
	else
		table.insert(packer.array, packer.current)

		packer.increment = 1
		packer.current = 0
	end
end

--[=[
Push true to the most significant bit.
]=]
@native
local function push_true(packer: Packer): ()
	local increment = packer.increment

	packer.current += increment

	if increment < 2 ^ 32 then
		packer.increment = increment * 0b10
	else
		table.insert(packer.array, packer.current)

		packer.increment = 1
		packer.current = 0
	end
end

--[=[
Push a boolean to the most significant bit.
]=]
@native
local function push(packer: Packer, bool: boolean): ()
	(bool and push_true or push_false)(packer)
end

--[=[
Evaluate the size, in bytes, of a bitpacker's array portion.
]=]
local function evaluate_array(packer: Packer): number
	return #packer.array * U32_BYTES
end

--[=[
Evaluate the size, in bytes, of a bitpacker's remainder portion.
]=]
local function evaluate_remainder(packer: Packer): number
	local next_increment = packer.increment

	-- default increment
	if next_increment == 0b1 then return 0 end

	local current_increment = next_increment / 0b10

	return uint_size(current_increment)
end

--[=[
Evaluate the size, in bytes, that a bitpacker will occupy once exported.
]=]
local function evaluate_packer(packer: Packer): number
	local data_bytes = evaluate_array(packer) + evaluate_remainder(packer)

	local vlq_bytes = vlq_size(data_bytes)

	return vlq_bytes + data_bytes
end

--[=[
Export a bitpacker into a buffer. Encodes length in bytes as vlq(2)
]=]
@native
local function export(buff: buffer, byte_ptr: number, packer: Packer): (number, buffer)
	local array_bytes = evaluate_array(packer)
	local remainder_bytes = evaluate_remainder(packer)

	local data_bytes = array_bytes + remainder_bytes

	byte_ptr, buff = ser_vlq2(buff, byte_ptr, data_bytes)

	local u32_array = packer.array

	local u32_array_len = #u32_array

	for i = 1, u32_array_len do
		buffer.writeu32(buff, byte_ptr, u32_array[i])
		byte_ptr += U32_BYTES
	end

	if remainder_bytes > 0 then
		lookup_uint_ser_static[remainder_bytes](buff, byte_ptr, packer.current)
		byte_ptr += remainder_bytes
	end

	return byte_ptr, buff
end

local import
do
	local bitfield_const_lookup = table.create((2 ^ 8 - 1)) :: { [number]: { [number]: boolean } }
	do
		local outer_index = 0
		for encoded = 0, 2 ^ 8 - 1 do
			-- You can do this with a contiguous table and multiplying by 8, but this costs ~0.015 mb of memory, and is
			-- simpler / more performant.
			local inner_tbl = table.create(8) :: { boolean }
			local inner_index = 1

			for test_exp = 0, 7 do
				inner_tbl[inner_index] = bit32.btest(encoded, 2 ^ test_exp)
				inner_index += 1
			end

			bitfield_const_lookup[outer_index] = inner_tbl

			outer_index += 1
		end
	end

	--[=[
	Import a bitunpacker from a buffer.
	]=]
	@native
	function import(buff: buffer, byte_ptr: number): (number, Unpacker)
		local byte_count
		byte_ptr, byte_count = des_vlq2(buff, byte_ptr)

		local bits_output = table.create(byte_count * 8) :: { true | false }
		local output_index = 1

		local encoded: number
		for byte = 0, byte_count - 1 do
			encoded = buffer.readu8(buff, byte_ptr)
			byte_ptr += 1

			table.move(bitfield_const_lookup[encoded], 1, 8, output_index, bits_output)

			output_index += 8
		end

		return byte_ptr, {
			array = bits_output,
			pos = 1,
		}
	end
end

--[=[
Read the next boolean from a bitunpacker.
]=]
@native
local function read(unpacker: Unpacker): boolean
	local pos = unpacker.pos

	unpacker.pos = pos + 1

	return unpacker.array[pos]
end

local api = {
	packer = packer,
	reset = reset,
	push_false = push_false,
	push_true = push_true,
	push = push,
	evaluate_array = evaluate_array,
	evaluate_remainder = evaluate_remainder,
	evaluate_packer = evaluate_packer,
	export = export,
	import = import,
	read = read,
}

return api
