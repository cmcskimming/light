--[[MIT License Copyright (c) 2025 @hardlyardi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]
--[[
--FOR DESCRIPTIONS OF API & CODE FUNCTION, ETC: https://light.ardi.gg/
--FOR ISSUES, BUG REPORTS, OR FEATURE REQUESTS: https://light.ardi.gg/github
--ROBLOX OSS SERVER: https://discord.com/invite/5KjV64PA3d
--MY DISCORD (please only contact for important questions): https://discord.com/users/331399684415553538/
]]
--[[
Bitpacking utility object
TODO: Consider adding caching to packer fields on push
TODO: Investigate bitpack perf of numeric index instead of hash (rip maintainability)
]]
local PACK_DEFAULT_INCREMENT = 1
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

export type Identity = {
	array: { u32 },
	current: u8 | u16 | u24 | u32,
	increment: u32,
}

export type UnpackerIdentity = {
	array: { boolean },
	read_index: number,
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
local function constructor(): Identity
	return {
		array = {} :: { u32 },
		current = 0 :: u32,
		increment = PACK_DEFAULT_INCREMENT :: u32,
	}
end

--[=[
Reset a bitpacker's bit array, current progress, and increment, so it can be reused.
]=]
local function reset(packer: Identity): ()
	packer.array = {} :: { u32 }
	packer.current = 0 :: u32
	packer.increment = PACK_DEFAULT_INCREMENT :: u32
end

--[=[
Push false to the most significant bit.
]=]
@native
local function push_false(packer: Identity): ()
	local increment = packer.increment

	if increment < 2 ^ 32 then
		packer.increment = increment * 0b10
	else
		table.insert(packer.array, packer.current)

		packer.increment = PACK_DEFAULT_INCREMENT
		packer.current = 0
	end
end

--[=[
Push true to the most significant bit.
]=]
@native
local function push_true(packer: Identity): ()
	local increment = packer.increment

	packer.current += increment

	if increment < 2 ^ 32 then
		packer.increment = increment * 0b10
	else
		table.insert(packer.array, packer.current)

		packer.increment = PACK_DEFAULT_INCREMENT
		packer.current = 0
	end
end

--[=[
Push a boolean to the most significant bit.
]=]
@native
local function push(packer: Identity, bool: boolean): ()
	(bool and push_true or push_false)(packer)
end

--[=[
Evaluate the size, in bytes, of a bitpacker's array portion.
]=]
local function evaluate_array(packer: Identity): number
	return #packer.array * U32_BYTES
end

--[=[
Evaluate the size, in bytes, of a bitpacker's remainder portion.
]=]
local function evaluate_remainder(packer: Identity): number
	local next_increment = packer.increment

	-- default increment
	if next_increment == 0b1 then return 0 end

	local current_increment = next_increment / 0b10

	return uint_size(current_increment)
end

--[=[
Evaluate the size, in bytes, that a bitpacker will occupy once exported.
]=]
local function evaluate_packer(packer: Identity): number
	local data_bytes = evaluate_array(packer) + evaluate_remainder(packer)

	local vlq_bytes = vlq_size(data_bytes)

	return vlq_bytes + data_bytes
end

--[=[
Check if a bitpack has had any fields pushed to it.
]=]
local function bitpacker_contains_data(packer: Identity): boolean
	return packer.increment ~= PACK_DEFAULT_INCREMENT or #packer.array > 0
end

--[=[
Export a bitpacker into a buffer. Encodes length in bytes as vlq(2)
]=]
@native
local function export(buff: buffer, byte_ptr: number, packer: Identity): (number, buffer)
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
local import_byte
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
	function import(buff: buffer, byte_ptr: number): (number, UnpackerIdentity)
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
			read_index = 1,
		}
	end

	--[=[
	Import a series of bits from a u8
	]=]
	@native
	function import_byte(
		buff: buffer,
		byte_ptr: number
	): (
		number,
		boolean,
		boolean,
		boolean,
		boolean,
		boolean,
		boolean,
		boolean,
		boolean
	)
		local decoded = buffer.readu8(buff, byte_ptr)
		byte_ptr += 1

		local decoded_tbl = bitfield_const_lookup[decoded]

		return byte_ptr,
			decoded_tbl[1],
			decoded_tbl[2],
			decoded_tbl[3],
			decoded_tbl[4],
			decoded_tbl[5],
			decoded_tbl[6],
			decoded_tbl[7],
			decoded_tbl[8]
	end
end

--[=[
Read the next boolean from a bitunpacker.
]=]
@native
local function read(unpacker: UnpackerIdentity): boolean
	local read = unpacker.read_index

	unpacker.read_index = read + 1

	local output = unpacker.array[read]

	return output
end

local api = {
	new = constructor,
	reset = reset,
	push_false = push_false,
	push_true = push_true,
	push = push,
	evaluate_array = evaluate_array,
	evaluate_remainder = evaluate_remainder,
	evaluate_packer = evaluate_packer,
	contains_data = bitpacker_contains_data,
	export = export,
	import = import,
	import_byte = import_byte,
	read = read,
}

return api
