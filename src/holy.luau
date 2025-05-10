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
--!strict
--!optimize 2
--!nolint LocalShadow
type Set<K, V = true?> = { [K]: V }

export type Datatype<T = any> = number & { __HOLY_T: T }

export type SerNoRealloc<Input = any> = (buff: buffer, byte_ptr: number, input: Input) -> (number)
export type SerStatic<Input = any> = (buff: buffer, byte_ptr: number, input: Input) -> ()
export type Ser<Input = any> = (buff: buffer, byte_ptr: number, input: Input) -> (number, buffer)
export type Des<Output = any> = (buff: buffer, byte_ptr: number) -> (number, Output)

type MetadataSet<Data = true?> = Set<Datatype, Data>

local metadata = {
	static_size = {} :: MetadataSet<number>,
	ser_static = {} :: MetadataSet<SerStatic>,
	ser_no_realloc = {} :: MetadataSet<SerNoRealloc>,
	ser = {} :: MetadataSet<Ser>,
	des = {} :: MetadataSet<Des>,
	literal_value = {} :: MetadataSet<any>,

	is_number = {} :: MetadataSet,
	is_nilable = {} :: MetadataSet,
	is_literal = {} :: MetadataSet,
}

local CONST_LOOKUPS = {}

local IS_STFU_MODE = false

local _err = error

local function stfu(shut_up: boolean?): ()
	if shut_up or shut_up == nil then
		IS_STFU_MODE = true
	else
		IS_STFU_MODE = false
	end
end

local function stfu_check(): ()
	if IS_STFU_MODE then
		_err()
	end
end

local function is_stfu(): boolean
	return IS_STFU_MODE
end

local function fetch_ser_no_realloc<T>(
	datatype: Datatype<T>
): SerNoRealloc<T>
	return metadata.ser_no_realloc[datatype]
end

local function fetch_ser_static<T>(
	datatype: Datatype<T>
): SerStatic<T>
	return metadata.ser_static[datatype]
end

local function fetch_ser<T>(
	datatype: Datatype<T>
): Ser<T>
	return metadata.ser[datatype]
end

local function fetch_des<T>(
	datatype: Datatype<T>
): Des<T>
	return metadata.des[datatype]
end

local function ordered_hash(...: any): string
	return table.concat({ ... }, "\126\002")
end

--[=[
Returns the minimum number of bytes required to encode a given unsigned int.
]=]
local function uint_size_bytes(uint: number): number
	local check = 2^8
	for bytes = 1, 7 do
		if uint >= check then
			check *= 2^8
			continue
		end
		return bytes
	end
	stfu_check()
	error(debug.traceback("uint size too big"))
end

--[=[
Returns the minimum number of bytes required to encode a given unsigned int as a VLQ value.
]=]
local function vlq_size_bytes(uint: number): number
	local check = 2^7
	for bytes = 1, 7 do
		if uint >= check then
			check *= 2^7
			continue
		end
		return bytes
	end
	stfu_check()
	error(debug.traceback("vlq too big"))
end

local function check_datatype_exists(datatype: any): boolean
	if metadata.ser[datatype] == nil then
		return false
	end
	if metadata.des[datatype] == nil then
		return false
	end
	return true
end

local function copy_datatype(src: Datatype, target: Datatype)
	if not check_datatype_exists(src) then
		error(debug.traceback(`Failed to copy datatype, DatatypeId<{src}> was not a valid datatype`))
	end
	for _, copyable in metadata :: {[string]: MetadataSet<any>} do
		copyable[target] = copyable[src]
	end
end

local new_datatype
do
	-- Starting datatype IDs at two to support implicit table declaration syntax in external tools. Kinda messy but if it
	-- works it works
	-- Luau
	local current_id = (2 :: any) :: Datatype
	function new_datatype<InputOutput>(static_size: number?): Datatype<InputOutput>
		local created_id = current_id

		metadata.static_size[created_id] = static_size

		current_id += 1
		
		return created_id :: any
	end
end

local export_datatype
do
	function export_datatype<T>(datatype: Datatype<T>): T
		return datatype :: any
	end
end

local datatypes = {}

do
	local static_size = 1
	local u8 = new_datatype(static_size)
	metadata.is_number[u8] = true
	
	@native
	local function u8_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): (number)
		buffer.writeu8(buff, byte_ptr, input)
		byte_ptr += static_size
		return byte_ptr
	end

	@native
	local function u8_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
		local len = buffer.len(buff)
		
		local target_ptr = byte_ptr + static_size
		--stylua: ignore
		do -- alloc
			if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
		end
		
		buffer.writeu8(buff, byte_ptr, input)
		--byte_ptr += static_size
		
		return target_ptr, buff
	end
	
	@native
	local function u8_des(buff: buffer, byte_ptr: number): (number, number)
		local output = buffer.readu8(buff, byte_ptr)
		byte_ptr += 1
		return byte_ptr, output
	end

	metadata.ser_no_realloc[u8] = u8_ser_no_realloc
	metadata.ser_static[u8] = buffer.writeu8 :: SerStatic
	metadata.ser[u8] = u8_ser
	metadata.des[u8] = u8_des

datatypes.u8 = u8 :: Datatype<number> end

do
	local static_size = 2
	local u16 = new_datatype(static_size)
	metadata.is_number[u16] = true
	
	@native
	local function u16_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): (number)
		buffer.writeu16(buff, byte_ptr, input)
		byte_ptr += static_size
		return byte_ptr
	end

	@native
	local function u16_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
		local len = buffer.len(buff)
		
		local target_ptr = byte_ptr + static_size
		--stylua: ignore
		do -- alloc
			if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
		end
		
		buffer.writeu16(buff, byte_ptr, input)
		--byte_ptr += static_size
		
		return target_ptr, buff
	end
	
	@native
	local function u16_des(buff: buffer, byte_ptr: number): (number, number)
		local output = buffer.readu16(buff, byte_ptr)
		byte_ptr += static_size
		return byte_ptr, output
	end

	metadata.ser_no_realloc[u16] = u16_ser_no_realloc
	metadata.ser_static[u16] = buffer.writeu16 :: SerStatic
	metadata.ser[u16] = u16_ser
	metadata.des[u16] = u16_des

datatypes.u16 = u16 :: Datatype<number> end

do
	local static_size = 3
	local u24 = new_datatype(static_size)
	metadata.is_number[u24] = true

	@native
	local function u24_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): (number)
		buffer.writeu8(buff, byte_ptr, input)
		input //= 2^8
		byte_ptr += 1

		buffer.writeu16(buff, byte_ptr, input)
		byte_ptr += 2

		return byte_ptr
	end

	@native
	local function u24_ser_static(buff: buffer, byte_ptr: number, input: any): ()
		buffer.writeu8(buff, byte_ptr, input)
		input //= 2^8
		byte_ptr += 1

		buffer.writeu16(buff, byte_ptr, input)
	end

	@native
	local function u24_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
		local len = buffer.len(buff)

		local target_ptr = byte_ptr + static_size
		--stylua: ignore
		do -- alloc
			if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
		end

		buffer.writeu8(buff, byte_ptr, input)
		input //= 2^8
		byte_ptr += 1

		buffer.writeu16(buff, byte_ptr, input)

		return target_ptr, buff
	end

	@native
	local function u24_des(buff: buffer, byte_ptr: number): (number, number)
		local output = buffer.readu8(buff, byte_ptr)
		byte_ptr += 1
		output += buffer.readu16(buff, byte_ptr) * (2 ^ 8)
		byte_ptr += 2
		return byte_ptr, output
	end

	metadata.ser_no_realloc[u24] = u24_ser_no_realloc
	metadata.ser_static[u24] = u24_ser_static
	metadata.ser[u24] = u24_ser
	metadata.des[u24] = u24_des

datatypes.u24 = u24 :: Datatype<number> end

do
	local static_size = 4
	local u32 = new_datatype(static_size)
	metadata.is_number[u32] = true
	
	@native
	local function u32_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): (number)
		buffer.writeu32(buff, byte_ptr, input)
		byte_ptr += static_size
		return byte_ptr
	end

	@native
	local function u32_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
		local len = buffer.len(buff)
		
		local target_ptr = byte_ptr + static_size
		--stylua: ignore
		do -- alloc
			if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
		end
		
		buffer.writeu32(buff, byte_ptr, input)
		return target_ptr, buff
	end
	
	@native
	local function u32_des(buff: buffer, byte_ptr: number): (number, number)
		local output = buffer.readu32(buff, byte_ptr)
		byte_ptr += static_size
		return byte_ptr, output
	end
	
	metadata.ser_no_realloc[u32] = u32_ser_no_realloc
	metadata.ser_static[u32] = buffer.writeu32 :: SerStatic
	metadata.ser[u32] = u32_ser
	metadata.des[u32] = u32_des

datatypes.u32 = u32 :: Datatype<number> end

do
	local u40 = new_datatype()
	local static_size = 5
	metadata.is_number[u40] = true

	@native
	local function u40_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): (number)
		buffer.writeu8(buff, byte_ptr, input)
		input //= 2^8
		byte_ptr += 1

		buffer.writeu32(buff, byte_ptr, input)
		byte_ptr += 4
		
		return byte_ptr
	end

	@native
	local function u40_ser_static(buff: buffer, byte_ptr: number, input: any): ()
		buffer.writeu8(buff, byte_ptr, input)
		input //= 2^8
		byte_ptr += 1

		buffer.writeu32(buff, byte_ptr, input)
	end

	@native
	local function u40_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
		local len = buffer.len(buff)

		local target_ptr = byte_ptr + static_size
		--stylua: ignore
		do -- alloc
			if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
		end

		buffer.writeu8(buff, byte_ptr, input)
		input //= 2^8
		byte_ptr += 1

		buffer.writeu32(buff, byte_ptr, input)
		byte_ptr += 4

		return target_ptr, buff
	end

	@native
	local function u40_des(buff: buffer, byte_ptr: number): (number, number)
		local output = buffer.readu8(buff, byte_ptr)
		byte_ptr += 1

		output += buffer.readu32(buff, byte_ptr) * (2^8)
		byte_ptr += 4

		return byte_ptr, output
	end

	metadata.ser_no_realloc[u40] = u40_ser_no_realloc
	metadata.ser_static[u40] = u40_ser_static
	metadata.ser[u40] = u40_ser
	metadata.des[u40] = u40_des

datatypes.u40 = u40 :: Datatype<number> end

do
	local static_size = 6
	local u48 = new_datatype(static_size)
	metadata.is_number[u48] = true

	@native
	local function u48_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): (number)
		buffer.writeu16(buff, byte_ptr, input)
		input //= 2^16
		byte_ptr += 2

		buffer.writeu32(buff, byte_ptr, input)
		byte_ptr += 4
		
		return byte_ptr
	end

	@native
	local function u48_ser_static(buff: buffer, byte_ptr: number, input: any): ()
		buffer.writeu16(buff, byte_ptr, input)
		input //= 2^16
		byte_ptr += 2

		buffer.writeu32(buff, byte_ptr, input)
	end

	@native
	local function u48_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
		local len = buffer.len(buff)

		local target_ptr = byte_ptr + static_size
		--stylua: ignore
		do -- alloc
			if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
		end

		buffer.writeu16(buff, byte_ptr, input)
		input //= 2^16
		byte_ptr += 2

		buffer.writeu32(buff, byte_ptr, input)
		byte_ptr += 4

		return target_ptr, buff
	end

	@native
	local function u48_des(buff: buffer, byte_ptr: number): (number, number)
		local output = buffer.readu16(buff, byte_ptr)
		byte_ptr += 2

		output += buffer.readu32(buff, byte_ptr) * (2^16)
		byte_ptr += 4

		return byte_ptr, output
	end

	metadata.ser_no_realloc[u48] = u48_ser_no_realloc
	metadata.ser_static[u48] = u48_ser_static
	metadata.ser[u48] = u48_ser
	metadata.des[u48] = u48_des

datatypes.u48 = u48 :: Datatype<number> end

do
	local static_size = 7
	local u53 = new_datatype(static_size)
	metadata.is_number[u53] = true

	@native
	local function u53_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): (number)
		buffer.writeu8(buff, byte_ptr, input)
		input //= 2^8
		byte_ptr += 1

		buffer.writeu16(buff, byte_ptr, input)
		input //= 2^16
		byte_ptr += 2

		buffer.writeu32(buff, byte_ptr, input)
		byte_ptr += 4
		
		return byte_ptr
	end

	@native
	local function u53_ser_static(buff: buffer, byte_ptr: number, input: any): ()
		buffer.writeu8(buff, byte_ptr, input)
		input //= 2^8
		byte_ptr += 1

		buffer.writeu16(buff, byte_ptr, input)
		input //= 2^16
		byte_ptr += 2

		buffer.writeu32(buff, byte_ptr, input)
	end

	@native
	local function u53_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
		local len = buffer.len(buff)

		local target_ptr = byte_ptr + static_size
		--stylua: ignore
		do -- alloc
			if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
		end

		buffer.writeu8(buff, byte_ptr, input)
		input //= 2^8
		byte_ptr += 1

		buffer.writeu16(buff, byte_ptr, input)
		input //= 2^16
		byte_ptr += 2

		buffer.writeu32(buff, byte_ptr, input)
		byte_ptr += 4

		return target_ptr, buff
	end

	@native
	local function u53_des(buff: buffer, byte_ptr: number): (number, number)
		local output = buffer.readu8(buff, byte_ptr)
		byte_ptr += 1

		output += buffer.readu16(buff, byte_ptr) * (2^8)
		byte_ptr += 2

		output += buffer.readu32(buff, byte_ptr) * (2^8) * (2^16)
		byte_ptr += 4

		return byte_ptr, output
	end

	metadata.ser_no_realloc[u53] = u53_ser_no_realloc
	metadata.ser_static[u53] = u53_ser_static
	metadata.ser[u53] = u53_ser
	metadata.des[u53] = u53_des

datatypes.u53 = u53 :: Datatype<number> end

CONST_LOOKUPS.uint = {
	type = {
		[1] = datatypes.u8,
		[2] = datatypes.u16,
		[3] = datatypes.u24,
		[4] = datatypes.u32,
		[5] = datatypes.u40,
		[6] = datatypes.u48,
		[7] = datatypes.u53,
	} :: Set<number, Datatype<number>>,
	ser_no_realloc = {
		[1] = metadata.ser_no_realloc[datatypes.u8],
		[2] = metadata.ser_no_realloc[datatypes.u16],
		[3] = metadata.ser_no_realloc[datatypes.u24],
		[4] = metadata.ser_no_realloc[datatypes.u32],
		[5] = metadata.ser_no_realloc[datatypes.u40],
		[6] = metadata.ser_no_realloc[datatypes.u48],
		[7] = metadata.ser_no_realloc[datatypes.u53],
	} :: Set<number, SerNoRealloc>,
	ser_static = {
		[1] = metadata.ser_static[datatypes.u8],
		[2] = metadata.ser_static[datatypes.u16],
		[3] = metadata.ser_static[datatypes.u24],
		[4] = metadata.ser_static[datatypes.u32],
		[5] = metadata.ser_static[datatypes.u40],
		[6] = metadata.ser_static[datatypes.u48],
		[7] = metadata.ser_static[datatypes.u53],
	} :: Set<number, SerStatic>,
	ser = {
		[1] = metadata.ser[datatypes.u8],
		[2] = metadata.ser[datatypes.u16],
		[3] = metadata.ser[datatypes.u24],
		[4] = metadata.ser[datatypes.u32],
		[5] = metadata.ser[datatypes.u40],
		[6] = metadata.ser[datatypes.u48],
		[7] = metadata.ser[datatypes.u53],
	} :: Set<number, Ser>,
	des = {
		[1] = metadata.des[datatypes.u8],
		[2] = metadata.des[datatypes.u16],
		[3] = metadata.des[datatypes.u24],
		[4] = metadata.des[datatypes.u32],
		[5] = metadata.des[datatypes.u40],
		[6] = metadata.des[datatypes.u48],
		[7] = metadata.des[datatypes.u53],
	} :: Set<number, Des>,
}

do
	local static_size = 1
	local i8 = new_datatype(static_size)
	metadata.is_number[i8] = true

	@native
	local function i8_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): (number)
		buffer.writei8(buff, byte_ptr, input)
		byte_ptr += static_size

		return byte_ptr
	end

	@native
	local function i8_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
		local len = buffer.len(buff)

		local target_ptr = byte_ptr + static_size
		--stylua: ignore
		do -- alloc
			if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
		end

		buffer.writei8(buff, byte_ptr, input)

		return target_ptr, buff
	end

	@native
	local function i8_des(buff: buffer, byte_ptr: number): (number, number)
		local output = buffer.readi8(buff, byte_ptr)
		byte_ptr += static_size
		return byte_ptr, output
	end

	metadata.ser_no_realloc[i8] = i8_ser_no_realloc
	metadata.ser_static[i8] = buffer.writei8 :: SerStatic
	metadata.ser[i8] = i8_ser
	metadata.des[i8] = i8_des

datatypes.i8 = i8 :: Datatype<number> end

do
	local static_size = 2
	local i16 = new_datatype(static_size)
	metadata.is_number[i16] = true

	@native
	local function i16_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): (number)
		buffer.writei8(buff, byte_ptr, input)
		byte_ptr += static_size

		return byte_ptr
	end

	@native
	local function i16_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
		local len = buffer.len(buff)

		local target_ptr = byte_ptr + static_size
		--stylua: ignore
		do -- alloc
			if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
		end

		buffer.writei16(buff, byte_ptr, input)

		return target_ptr, buff
	end

	@native
	local function i16_des(buff: buffer, byte_ptr: number): (number, number)
		local output = buffer.readi16(buff, byte_ptr)
		byte_ptr += static_size
		return byte_ptr, output
	end

	metadata.ser_no_realloc[i16] = i16_ser_no_realloc
	metadata.ser_static[i16] = buffer.writei16 :: SerStatic
	metadata.ser[i16] = i16_ser
	metadata.des[i16] = i16_des

datatypes.i16 = i16 :: Datatype<number> end

do
	local static_size = 3
	local i24 = new_datatype(static_size)
	metadata.is_number[i24] = true

	@native
	local function i24_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): (number)
		input += 2^23

		buffer.writeu8(buff, byte_ptr, input)
		input //= 2^8
		byte_ptr += 1

		buffer.writeu16(buff, byte_ptr, input)
		byte_ptr += 2

		return byte_ptr
	end

	@native
	local function i24_ser_static(buff: buffer, byte_ptr: number, input: any): ()
		input += 2^23

		buffer.writeu8(buff, byte_ptr, input)
		input //= 2^8
		byte_ptr += 1

		buffer.writeu16(buff, byte_ptr, input)
	end

	@native
	local function i24_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
		input += 2^23
		local len = buffer.len(buff)

		local target_ptr = byte_ptr + static_size
		--stylua: ignore
		do -- alloc
			if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
		end

		buffer.writeu8(buff, byte_ptr, input)
		input //= 2^8
		byte_ptr += 1

		buffer.writeu16(buff, byte_ptr, input)

		return target_ptr, buff
	end

	@native
	local function i24_des(buff: buffer, byte_ptr: number): (number, number)
		local output = buffer.readu8(buff, byte_ptr)
		byte_ptr += 1

		output += buffer.readu16(buff, byte_ptr) * (2^8)
		byte_ptr += 2

		output -= 2^23

		return byte_ptr, output
	end

	metadata.ser_no_realloc[i24] = i24_ser_no_realloc
	metadata.ser_static[i24] = i24_ser_static
	metadata.ser[i24] = i24_ser
	metadata.des[i24] = i24_des
datatypes.i24 = i24 :: Datatype<number> end

do
	local static_size = 4
	local i32 = new_datatype(static_size)
	metadata.is_number[i32] = true

	@native
	local function i32_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): (number)
		buffer.writei32(buff, byte_ptr, input)
		byte_ptr += static_size

		return byte_ptr
	end

	@native
	local function i32_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
		local len = buffer.len(buff)

		local target_ptr = byte_ptr + static_size
		--stylua: ignore
		do -- alloc
			if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
		end

		buffer.writei32(buff, byte_ptr, input)

		return target_ptr, buff
	end

	@native
	local function i32_des(buff: buffer, byte_ptr: number): (number, number)
		local output = buffer.readi32(buff, byte_ptr)
		byte_ptr += static_size
		return byte_ptr, output
	end

	metadata.ser_no_realloc[i32] = i32_ser_no_realloc
	metadata.ser_static[i32] = buffer.writei32 :: SerStatic
	metadata.ser[i32] = i32_ser
	metadata.des[i32] = i32_des
datatypes.i32 = i32 :: Datatype<number> end

do
	local static_size = 5
	local i40 = new_datatype(static_size)
	metadata.is_number[i40] = true

	@native
	local function i40_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): (number)
		input += 2^39

		buffer.writeu8(buff, byte_ptr, input)
		input //= 2^8
		byte_ptr += 1

		buffer.writeu32(buff, byte_ptr, input)
		byte_ptr += 4

		return byte_ptr
	end

	@native
	local function i40_ser_static(buff: buffer, byte_ptr: number, input: any): ()
		input += 2^39

		buffer.writeu8(buff, byte_ptr, input)
		input //= 2^8
		byte_ptr += 1

		buffer.writeu32(buff, byte_ptr, input)
	end

	@native
	local function i40_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
		input += 2^39
		local len = buffer.len(buff)

		local target_ptr = byte_ptr + static_size
		--stylua: ignore
		do -- alloc
			if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
		end

		buffer.writeu8(buff, byte_ptr, input)
		input //= 2^8
		byte_ptr += 1

		buffer.writeu32(buff, byte_ptr, input)

		return target_ptr, buff
	end

	@native
	local function i40_des(buff: buffer, byte_ptr: number): (number, number)
		local output = buffer.readu8(buff, byte_ptr)
		byte_ptr += 1

		output += buffer.readu32(buff, byte_ptr) * (2^8)
		byte_ptr += 4

		output -= 2^39

		return byte_ptr, output
	end

	metadata.ser_no_realloc[i40] = i40_ser_no_realloc
	metadata.ser_static[i40] = i40_ser_static
	metadata.ser[i40] = i40_ser
	metadata.des[i40] = i40_des
datatypes.i40 = i40 :: Datatype<number> end

do
	local static_size = 6
	local i48 = new_datatype(static_size)
	metadata.is_number[i48] = true

	@native
	local function i48_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): (number)
		input += 2^47

		buffer.writeu16(buff, byte_ptr, input)
		input //= 2^16
		byte_ptr += 2

		buffer.writeu32(buff, byte_ptr, input)
		byte_ptr += 4

		return byte_ptr
	end

	@native
	local function i48_ser_static(buff: buffer, byte_ptr: number, input: any): ()
		input += 2^47

		buffer.writeu16(buff, byte_ptr, input)
		input //= 2^16
		byte_ptr += 2

		buffer.writeu32(buff, byte_ptr, input)
	end

	@native
	local function i48_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
		input += 2^47
		local len = buffer.len(buff)

		local target_ptr = byte_ptr + static_size
		--stylua: ignore
		do -- alloc
			if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
		end

		buffer.writeu16(buff, byte_ptr, input)
		input //= 2^16
		byte_ptr += 2

		buffer.writeu32(buff, byte_ptr, input)

		return target_ptr, buff
	end

	@native
	local function i48_des(buff: buffer, byte_ptr: number): (number, number)
		local output = buffer.readu16(buff, byte_ptr)
		byte_ptr += 2

		output += buffer.readu32(buff, byte_ptr) * (2^16)
		byte_ptr += 4

		output -= 2^47
		return byte_ptr, output
	end

	metadata.ser_no_realloc[i48] = i48_ser_no_realloc
	metadata.ser_static[i48] = i48_ser_static
	metadata.ser[i48] = i48_ser
	metadata.des[i48] = i48_des
datatypes.i48 = i48 :: Datatype<number> end

do
	local static_size = 7
	local i54 = new_datatype(static_size)
	metadata.is_number[i54] = true

	@native
	local function i54_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): (number)
		if input < 0 then
			input += 2^53
		end

		buffer.writeu8(buff, byte_ptr, input)
		input //= 2^8
		byte_ptr += 1

		buffer.writeu16(buff, byte_ptr, input)
		input //= 2^16
		byte_ptr += 2

		buffer.writeu32(buff, byte_ptr, input)
		byte_ptr += 4

		return byte_ptr
	end

	@native
	local function i54_ser_static(buff: buffer, byte_ptr: number, input: any): ()
		if input < 0 then
			input += 2^53
		end

		buffer.writeu8(buff, byte_ptr, input)
		input //= 2^8
		byte_ptr += 1

		buffer.writeu16(buff, byte_ptr, input)
		input //= 2^16
		byte_ptr += 2

		buffer.writeu32(buff, byte_ptr, input)
	end

	@native
	local function i54_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
		local len = buffer.len(buff)

		local target_ptr = byte_ptr + static_size
		--stylua: ignore
		do -- alloc
			if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
		end

		if input < 0 then
			input += 2^53
		end

		buffer.writeu8(buff, byte_ptr, input)
		input //= 2^8
		byte_ptr += 1
		buffer.writeu16(buff, byte_ptr, input)
		input //= 2^16
		byte_ptr += 2
		buffer.writeu32(buff, byte_ptr, input)

		return target_ptr, buff
	end

	@native
	local function i54_des(buff: buffer, byte_ptr: number): (number, number)
		local output = buffer.readu8(buff, byte_ptr)
		byte_ptr += 1

		output += buffer.readu16(buff, byte_ptr) * (2^8)
		byte_ptr += 2
		
		output += buffer.readu32(buff, byte_ptr) * (2^8) * (2^16)
		byte_ptr += 4

		if output >= 2^52 then
			output -= 2^53
		end

		return byte_ptr, output
	end

	metadata.ser_no_realloc[i54] = i54_ser_no_realloc
	metadata.ser_static[i54] = i54_ser_static
	metadata.ser[i54] = i54_ser
	metadata.des[i54] = i54_des

datatypes.i54 = i54 :: Datatype<number> end

CONST_LOOKUPS.int = {
	type = {
		[1] = datatypes.i8,
		[2] = datatypes.i16,
		[3] = datatypes.i24,
		[4] = datatypes.i32,
		[5] = datatypes.i40,
		[6] = datatypes.i48,
		[7] = datatypes.i54,
	} :: Set<number, Datatype<number>>,
	ser_no_realloc = {
		[1] = metadata.ser_no_realloc[datatypes.i8],
		[2] = metadata.ser_no_realloc[datatypes.i16],
		[3] = metadata.ser_no_realloc[datatypes.i24],
		[4] = metadata.ser_no_realloc[datatypes.i32],
		[5] = metadata.ser_no_realloc[datatypes.i40],
		[6] = metadata.ser_no_realloc[datatypes.i48],
		[7] = metadata.ser_no_realloc[datatypes.i54],
	} :: Set<number, SerNoRealloc>,
	ser_static = {
		[1] = metadata.ser_static[datatypes.i8],
		[2] = metadata.ser_static[datatypes.i16],
		[3] = metadata.ser_static[datatypes.i24],
		[4] = metadata.ser_static[datatypes.i32],
		[5] = metadata.ser_static[datatypes.i40],
		[6] = metadata.ser_static[datatypes.i48],
		[7] = metadata.ser_static[datatypes.i54],
	} :: Set<number, SerStatic>,
	ser = {
		[1] = metadata.ser[datatypes.i8],
		[2] = metadata.ser[datatypes.i16],
		[3] = metadata.ser[datatypes.i24],
		[4] = metadata.ser[datatypes.i32],
		[5] = metadata.ser[datatypes.i40],
		[6] = metadata.ser[datatypes.i48],
		[7] = metadata.ser[datatypes.i54],
	} :: Set<number, Ser>,
	des = {
		[1] = metadata.des[datatypes.i8],
		[2] = metadata.des[datatypes.i16],
		[3] = metadata.des[datatypes.i24],
		[4] = metadata.des[datatypes.i32],
		[5] = metadata.des[datatypes.i40],
		[6] = metadata.des[datatypes.i48],
		[7] = metadata.des[datatypes.i54],
	} :: Set<number, Des>,
}

do
	local static_size = 4
	local f32 = new_datatype(static_size)
	metadata.is_number[f32] = true

	@native
	local function f32_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): (number)
		buffer.writef32(buff, byte_ptr, input)
		byte_ptr += static_size

		return byte_ptr
	end

	@native
	local function f32_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
		local len = buffer.len(buff)

		local target_ptr = byte_ptr + static_size
		--stylua: ignore
		do -- alloc
			if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
		end

		buffer.writef32(buff, byte_ptr, input)

		return target_ptr, buff
	end

	@native
	local function f32_des(buff: buffer, byte_ptr: number): (number, number)
		local output = buffer.readf32(buff, byte_ptr)
		byte_ptr += static_size
		return byte_ptr, output
	end

	metadata.ser_no_realloc[f32] = f32_ser_no_realloc
	metadata.ser_static[f32] = buffer.writef32 :: SerStatic
	metadata.ser[f32] = f32_ser
	metadata.des[f32] = f32_des
datatypes.f32 = f32 :: Datatype<number> end

do
	local static_size = 8
	local f64 = new_datatype(static_size)
	metadata.is_number[f64] = true

	@native
	local function f64_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): (number)
		buffer.writef64(buff, byte_ptr, input)
		byte_ptr += static_size

		return byte_ptr
	end

	@native
	local function f64_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
		local len = buffer.len(buff)

		local target_ptr = byte_ptr + static_size
		--stylua: ignore
		do -- alloc
			if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
		end

		buffer.writef64(buff, byte_ptr, input)

		return target_ptr, buff
	end

	@native
	local function f64_des(buff: buffer, byte_ptr: number): (number, number)
		local output = buffer.readf64(buff, byte_ptr)
		byte_ptr += static_size
		return byte_ptr, output
	end

	metadata.ser_no_realloc[f64] = f64_ser_no_realloc
	metadata.ser_static[f64] = buffer.writef64 :: SerStatic
	metadata.ser[f64] = f64_ser
	metadata.des[f64] = f64_des
datatypes.f64 = f64 :: Datatype<number> end

CONST_LOOKUPS.float = {
	type = {
		[4] = datatypes.f32,
		[8] = datatypes.f64,
	} :: Set<number, Datatype<number>>,
	ser_no_realloc = {
		[4] = metadata.ser_no_realloc[datatypes.f32],
		[8] = metadata.ser_no_realloc[datatypes.f64],
	} :: Set<number, SerNoRealloc>,
	ser_static = {
		[4] = metadata.ser_static[datatypes.f32],
		[8] = metadata.ser_static[datatypes.f64],
	} :: Set<number, SerStatic>,
	ser = {
		[4] = metadata.ser[datatypes.f32],
		[8] = metadata.ser[datatypes.f64],
	} :: Set<number, Ser>,
	des = {
		[4] = metadata.des[datatypes.f32],
		[8] = metadata.des[datatypes.f64],
	} :: Set<number, Des>,
}

do
	local cache = {} :: Set<string, Datatype>

	local function literal<Value>(literal_value: Value): Datatype<Value>
		local literal_value = literal_value :: any

		-- hashing because value passed could be nil
		local hash = ordered_hash(literal_value, "__LIGHT_LITERAL")
		do
			local cached = cache[hash]
			if cached ~= nil then return cached :: any end
		end

		local literal_datatype = new_datatype()
		cache[hash] = literal_datatype

		local literal_ser_no_realloc, literal_ser_static, literal_ser, literal_des

		literal_ser_no_realloc = function(buff: buffer, byte_ptr: number): (number)
			return byte_ptr
		end
		literal_ser_static = function() end

		@native --dynamic_ncgen
		function literal_ser(buff: buffer, byte_ptr: number): (number, buffer)
			local len = buffer.len(buff)

			local target_ptr = byte_ptr
			--stylua: ignore
			do -- alloc
				if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
			end

			return byte_ptr, buff
		end

		@native --dynamic_ncgen
		function literal_des(buff: buffer, byte_ptr: number): (number, Value)
			return byte_ptr, literal_value
		end

		metadata.is_literal[literal_datatype] = true
		metadata.literal_value[literal_datatype] = literal_value

		metadata.ser_no_realloc[literal_datatype] = literal_ser_no_realloc
		metadata.ser_static[literal_datatype] = literal_ser_static
		metadata.ser[literal_datatype] = literal_ser
		metadata.des[literal_datatype] = literal_des

		if type(literal_value) == "number" then
			metadata.is_number[literal_datatype] = true
		elseif literal_value == nil then
			metadata.is_nilable[literal_datatype] = true
		end

		return literal_datatype :: any
	end

datatypes.literal = literal end

do
	local cache = {} :: Set<string, Datatype>

	local function clamp(minimum: number, maximum: number): Datatype<number>
		local hash = ordered_hash(minimum, maximum)
		do
			local cached = cache[hash]
			if cached ~= nil then return cached :: any end
		end

		if typeof(minimum) ~= "number" then
			error(debug.traceback(`Invalid clamp: Minimum should be a number. Got type: {typeof(minimum)}`))
		elseif minimum ~= minimum then
			error(debug.traceback(`Invalid clamp: Minimum should not be nan`))
		elseif (minimum // 1) ~= minimum then
			error(debug.traceback(`Invalid clamp: Minimum should be an integer. Got: {minimum}`))
		elseif typeof(maximum) ~= "number" then
			error(debug.traceback(`Invalid clamp: Maximum should be a number. Got type: {typeof(maximum)}`))
		elseif maximum ~= maximum then
			error(debug.traceback(`Invalid clamp: Maximum should not be nan`))
		elseif (maximum // 1) ~= maximum then
			error(debug.traceback(`Invalid clamp: Maximum should be an integer. Got: {maximum}`))
		elseif minimum > maximum then
			error(debug.traceback(`Invalid clamp: Minimum should not be higher than Maximum`))
		elseif minimum == maximum then
			error(debug.traceback(`Invalid clamp: Minimum should not equal maximum. Use a literal instead.`))
		end

		local range_bytes = uint_size_bytes(maximum - minimum)

		local clamp_datatype = new_datatype(range_bytes)
		cache[hash] = clamp_datatype

		local uint_ser_static, uint_ser, uint_des =
			CONST_LOOKUPS.uint.ser_static[range_bytes],
			CONST_LOOKUPS.uint.ser[range_bytes],
			CONST_LOOKUPS.uint.des[range_bytes]

		@native --dynamic_ncgen
		local function clamp_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): (number)
			input = math.clamp(input, minimum, maximum)
			input -= minimum

			uint_ser_static(buff, byte_ptr, input)
			byte_ptr += range_bytes

			return byte_ptr
		end

		@native --dynamic_ncgen
		local function clamp_static_ser(buff: buffer, byte_ptr: number, input: any): ()
			input = math.clamp(input, minimum, maximum)
			input -= minimum
			uint_ser_static(buff, byte_ptr, input)
		end

		@native --dynamic_ncgen
		local function clamp_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
			input = math.clamp(input, minimum, maximum)
			input -= minimum
			return uint_ser(buff, byte_ptr, input)
		end

		@native --dynamic_ncgen
		local function clamp_des(buff: buffer, byte_ptr: number): (number, number)
			local output
			byte_ptr, output = uint_des(buff, byte_ptr)
			output += minimum
			return byte_ptr, math.clamp(output, minimum, maximum)
		end

		metadata.is_number[clamp_datatype] = true

		metadata.ser_no_realloc[clamp_datatype] = clamp_ser_no_realloc
		metadata.ser_static[clamp_datatype] = clamp_static_ser
		metadata.ser[clamp_datatype] = clamp_ser
		metadata.des[clamp_datatype] = clamp_des
		
		return clamp_datatype :: any
	end

datatypes.clamp = clamp end

do
	local cache = {} :: Set<string, Datatype>

	local function range(minimum: number, maximum: number): Datatype<number>
		local hash = ordered_hash(minimum, maximum)
		do
			local cached = cache[hash]
			if cached ~= nil then return cached :: any end
		end

		if typeof(minimum) ~= "number" then
			error(debug.traceback(`Invalid range: Minimum should be a number. Got type: {typeof(minimum)}`))
		elseif minimum ~= minimum then
			error(debug.traceback(`Invalid range: Minimum should not be nan`))
		elseif (minimum // 1) ~= minimum then
			error(debug.traceback(`Invalid range: Minimum should be an integer. Got: {minimum}`))
		elseif typeof(maximum) ~= "number" then
			error(debug.traceback(`Invalid range: Maximum should be a number. Got type: {typeof(maximum)}`))
		elseif maximum ~= maximum then
			error(debug.traceback(`Invalid range: Maximum should not be nan`))
		elseif (maximum // 1) ~= maximum then
			error(debug.traceback(`Invalid range: Maximum should be an integer. Got: {maximum}`))
		elseif minimum > maximum then
			error(debug.traceback(`Invalid range: Minimum should not be higher than Maximum`))
		elseif minimum == maximum then
			error(debug.traceback(`Invalid range: Minimum should not equal maximum.`))
		end

		local delta_bytes = uint_size_bytes(maximum - minimum)
		local output_maximum = maximum - minimum

		local range_datatype = new_datatype(delta_bytes)
		cache[hash] = range_datatype

		local uint_ser_static, uint_ser, uint_des =
			CONST_LOOKUPS.uint.ser_static[delta_bytes],
			CONST_LOOKUPS.uint.ser[delta_bytes],
			CONST_LOOKUPS.uint.des[delta_bytes]

		@native --dynamic_ncgen
		local function range_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): (number)
			if (input < minimum) or (input > maximum) then
				stfu_check()
				if input < 0 then
					error(`Failed to ser range: input below minimum: {minimum} (input {input})`)
				else
					error(`Failed to ser range: input below maximum: {maximum} (input {input})`)
				end
			end

			input -= minimum
			uint_ser_static(buff, byte_ptr, input)
			byte_ptr += delta_bytes

			return byte_ptr
		end

		@native --dynamic_ncgen
		local function range_static_ser(buff: buffer, byte_ptr: number, input: any): ()
			if (input < minimum) or (input > maximum) then
				stfu_check()
				if input < 0 then
					error(`Failed to ser range: input below minimum: {minimum} (input {input})`)
				else
					error(`Failed to ser range: input below maximum: {maximum} (input {input})`)
				end
			end

			input -= minimum
			uint_ser_static(buff, byte_ptr, input)
		end

		@native --dynamic_ncgen
		local function range_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
			if (input < minimum) or (input > maximum) then
				stfu_check()
				if input < 0 then
					error(`Failed to ser range: input below minimum: {minimum} (input {input})`)
				else
					error(`Failed to ser range: input below maximum: {maximum} (input {input})`)
				end
			end
			
			input -= minimum
			return uint_ser(buff, byte_ptr, input)
		end

		@native --dynamic_ncgen
		local function range_des(buff: buffer, byte_ptr: number): (number, number)
			local output
			byte_ptr, output = uint_des(buff, byte_ptr)

			if output > output_maximum then
				stfu_check()
				error(
					debug.traceback(
						`Invalid range deserialized: output exceeded the maximum of {maximum}`
					)
				)
			end

			output += minimum

			return byte_ptr, output
		end

		metadata.is_number[range_datatype] = true

		metadata.ser_no_realloc[range_datatype] = range_ser_no_realloc
		metadata.ser_static[range_datatype] = range_static_ser
		metadata.ser[range_datatype] = range_ser
		metadata.des[range_datatype] = range_des
		
		return range_datatype :: any
	end

datatypes.range = range end

do
	local cache = {} :: Set<number, Datatype>
	local function vlq(max_bytes: number?): Datatype<number>
		local max_bytes = max_bytes or 3
		do
			local cached = cache[max_bytes]
			if cached ~= nil then return cached :: any end
		end

		if typeof(max_bytes) ~= "number" then
			error(debug.traceback(`Invalid vlq: max_bytes should be a number. Got type: {typeof(max_bytes)}`))
		elseif max_bytes ~= max_bytes then
			error(debug.traceback(`Invalid vlq: max_bytes should not be nan`))
		elseif (max_bytes // 1) ~= max_bytes then
			error(debug.traceback(`Invalid vlq: max_bytes should be an integer. Got: {max_bytes}`))
		elseif max_bytes > 7 then
			error(debug.traceback(`Invalid vlq: max_bytes should be less than or equal to 7. Got: {max_bytes}`))
		elseif max_bytes < 1 then
			error(debug.traceback(`Invalid vlq: max_bytes should be greater than or equal to 1. Got: {max_bytes}`))
		end

		if max_bytes == 1 then
			return datatypes.range(0, 127)
		end

		local vlq_shape = new_datatype()
		cache[max_bytes] = vlq_shape

		local lookup_ser_static_uint = CONST_LOOKUPS.uint.ser_static

		@native --dynamic_ncgen
		local function vlq_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
			local output = 0
			local septet: number

			for byte = 1, max_bytes do
				local offset = (0b10^8) ^ (byte - 1)

				septet = input % 0b10^7
				output += septet * offset
				input //= 0b10^7

				if input >= 0b1 then
					output += 0b10000000 * offset
					continue
				end

				local len = buffer.len(buff)

				local target_ptr = byte_ptr + byte
				--stylua: ignore
				do -- alloc
					if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
				end

				local uint_ser = lookup_ser_static_uint[byte]
				uint_ser(buff, byte_ptr, output)

				return target_ptr, buff
			end

			stfu_check()
			error(debug.traceback(`Invalid vlq serialized: Expected length <= {0b10000000^max_bytes}`))
		end

		@native --dynamic_ncgen
		local function vlq_des(buff: buffer, byte_ptr: number): (number, number)
			local output = 0

			for septet = 0, max_bytes - 1 do
				local byte = buffer.readu8(buff, byte_ptr)
				byte_ptr += 1

				local tag = byte // 0b10000000
				byte %= 0b10000000
				output += byte * (0b10000000 ^ septet)

				if tag ~= 1 then
					break
				end
			end

			return byte_ptr, output
		end

		metadata.is_number[vlq_shape] = true

		metadata.ser[vlq_shape] = vlq_ser
		metadata.des[vlq_shape] = vlq_des

		return vlq_shape :: Datatype<number>
	end

datatypes.vlq = vlq end

do
	local cache = {} :: Set<Datatype<number>, Datatype<string>>

	local function str(length_datatype: Datatype<number>?): Datatype<string>
		local length_datatype = length_datatype or datatypes.vlq(3)
		do
			local cached = cache[length_datatype]
			if cached ~= nil then return cached end
		end

		if not check_datatype_exists(length_datatype) then
			error(debug.traceback(`Invalid str: Length provided is not a valid datatype.`))
		end
		if not metadata.is_number[length_datatype] then
			error(debug.traceback(`Invalid str: Length must be a valid number datatype.`))
		end

		local str_datatype = new_datatype()
		cache[length_datatype] = str_datatype

		local case_literal_len = metadata.is_literal[length_datatype]
		local case_static_len = metadata.static_size[length_datatype] ~= nil

		local string_ser_no_realloc, string_ser_static, string_ser, string_des

		if case_literal_len then
			local literal_len_value = metadata.literal_value[length_datatype]
			metadata.static_size[str_datatype] = literal_len_value

			@native
			function string_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): (number)
				buffer.writestring(buff, byte_ptr, input, literal_len_value)
				byte_ptr += literal_len_value

				return byte_ptr
			end

			@native
			function string_ser_static(buff: buffer, byte_ptr: number, input: any): ()
				buffer.writestring(buff, byte_ptr, input, literal_len_value)
			end

			@native
			function string_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
				local len = buffer.len(buff)

				local target_ptr = byte_ptr + literal_len_value
				--stylua: ignore
				do -- alloc
					if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
				end

				buffer.writestring(buff, byte_ptr, input, literal_len_value)
				return target_ptr, buff
			end

			@native
			function string_des(buff: buffer, byte_ptr: number): (number, string)
				local output = buffer.readstring(buff, byte_ptr, literal_len_value)
				byte_ptr += literal_len_value

				return byte_ptr, output
			end
		elseif case_static_len then
			local static_len_bytes = metadata.static_size[length_datatype]
			local static_ser_length = metadata.ser_static[length_datatype]
			local des_length = metadata.des[length_datatype]

			@native
			function string_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
				local str_len = #input
				local len = buffer.len(buff)

				local target_ptr = byte_ptr + static_len_bytes + str_len
				--stylua: ignore
				do -- alloc
					if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
				end

				static_ser_length(buff, byte_ptr, str_len)
				byte_ptr += static_len_bytes

				buffer.writestring(buff, byte_ptr, input, str_len)

				return target_ptr, buff
			end

			@native
			function string_des(buff: buffer, byte_ptr: number): (number, string)
				local str_len
				byte_ptr, str_len = des_length(buff, byte_ptr)

				local output = buffer.readstring(buff, byte_ptr, str_len)
				byte_ptr += str_len

				return byte_ptr, output
			end
		else
			local ser_length = metadata.ser[length_datatype]
			local des_length = metadata.des[length_datatype]

			@native
			function string_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
				local str_len = #input
				byte_ptr, buff = ser_length(buff, byte_ptr, str_len)

				local len = buffer.len(buff)

				local target_ptr = byte_ptr + str_len
				--stylua: ignore
				do -- alloc
					if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
				end

				buffer.writestring(buff, byte_ptr, input, str_len)

				return target_ptr, buff
			end

			@native
			function string_des(buff: buffer, byte_ptr: number): (number, string)
				local str_len
				byte_ptr, str_len = des_length(buff, byte_ptr)

				local output = buffer.readstring(buff, byte_ptr, str_len)
				byte_ptr += str_len
				return byte_ptr, output
			end
		end

		metadata.ser_no_realloc[str_datatype] = string_ser_no_realloc
		metadata.ser_static[str_datatype] = string_ser_static
		metadata.ser[str_datatype] = string_ser
		metadata.des[str_datatype] = string_des

		return str_datatype
	end

datatypes.str = str end

do
	local cache = {} :: Set<Datatype<number>, Datatype<buffer>>

	local function buff(length_datatype: Datatype<number>?): Datatype<buffer>
		local length_datatype = length_datatype or datatypes.vlq(3)
		do
			local cached = cache[length_datatype]
			if cached ~= nil then return cached end
		end
		
		if not check_datatype_exists(length_datatype) then
			error(debug.traceback(`Invalid buff: Length provided is not a valid datatype.`))
		end
		if not metadata.is_number[length_datatype] then
			error(debug.traceback(`Invalid buff: Length must be a valid number datatype.`))
		end

		local literal_len_value = metadata.literal_value[length_datatype]

		local case_literal_len = not not metadata.is_literal[length_datatype]
		local case_static_len = not not literal_len_value
		
		local buff_datatype = new_datatype(if case_literal_len then literal_len_value else nil)
		cache[length_datatype] = buff_datatype

		local buff_ser_no_realloc, buff_ser_static, buff_ser, buff_des

		if case_literal_len then
			@native --dynamic_ncgen
			function buff_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): (number)
				buffer.copy(buff, byte_ptr, input, 0, literal_len_value)
				byte_ptr += literal_len_value

				return byte_ptr
			end

			@native --dynamic_ncgen
			function buff_ser_static(buff: buffer, byte_ptr: number, input: any): ()
				buffer.copy(buff, byte_ptr, input, 0, literal_len_value)
			end

			@native --dynamic_ncgen
			function buff_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
				local len = buffer.len(buff)

				local target_ptr = byte_ptr + literal_len_value
				--stylua: ignore
				do -- alloc
					if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
				end

				buffer.copy(buff, byte_ptr, input, 0, literal_len_value)
				return target_ptr, buff
			end

			@native --dynamic_ncgen
			function buff_des(buff: buffer, byte_ptr: number): (number, buffer)
				local output = buffer.create(literal_len_value)
				buffer.copy(output, 0, buff, byte_ptr, literal_len_value)
				byte_ptr += literal_len_value

				return byte_ptr, output
			end
		elseif case_static_len then
			local static_len_bytes = metadata.static_size[length_datatype]
			local static_ser_length = metadata.ser_static[length_datatype]
			local des_length = metadata.des[length_datatype]

			@native --dynamic_ncgen
			function buff_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
				local buff_len = buffer.len(input)
				local len = buffer.len(buff)

				local target_ptr = byte_ptr + static_len_bytes + buff_len
				--stylua: ignore
				do -- alloc
					if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
				end

				static_ser_length(buff, byte_ptr, buff_len)
				byte_ptr += static_len_bytes

				buffer.copy(buff, byte_ptr, input, 0, buff_len)

				return target_ptr, buff
			end

			@native --dynamic_ncgen
			function buff_des(buff: buffer, byte_ptr: number): (number, buffer)
				local buff_len
				byte_ptr, buff_len = des_length(buff, byte_ptr)

				local output = buffer.create(buff_len)
				buffer.copy(output, 0, buff, byte_ptr, buff_len)
				byte_ptr += buff_len

				return byte_ptr, output
			end
		else
			local ser_length = metadata.ser[length_datatype]
			local des_length = metadata.des[length_datatype]

			@native
			function buff_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
				local buff_len = buffer.len(input)
				byte_ptr, buff = ser_length(buff, byte_ptr, buff_len)

				local len = buffer.len(buff)

				local target_ptr = byte_ptr + buff_len
				--stylua: ignore
				do -- alloc
					if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
				end

				buffer.copy(buff, byte_ptr, input, 0, buff_len)

				return target_ptr, buff
			end

			@native
			function buff_des(buff: buffer, byte_ptr: number): (number, buffer)
				local buff_len
				byte_ptr, buff_len = des_length(buff, byte_ptr)

				local output = buffer.create(buff_len)
				buffer.copy(output, 0, buff, byte_ptr, buff_len)
				byte_ptr += buff_len

				return byte_ptr, output
			end
		end

		metadata.ser_no_realloc[buff_datatype] = buff_ser_no_realloc
		metadata.ser_static[buff_datatype] = buff_ser_static
		metadata.ser[buff_datatype] = buff_ser
		metadata.des[buff_datatype] = buff_des

		return buff_datatype
	end

datatypes.buff = buff end

do
	local cache = {} :: Set<string, Datatype<{any}>>

	local function arr<Item>(item_datatype: Datatype<Item>, length_datatype: Datatype<number>?): Datatype<{Item}>
		local length_datatype = length_datatype or datatypes.u16

		local hash = ordered_hash(item_datatype, length_datatype)
		do
			local cached = cache[hash]
			if cached ~= nil then return cached end
		end

		if not metadata.is_number[length_datatype] then
			error(debug.traceback(`Invalid arr: length must be a valid number datatype, got id: "{length_datatype}"`))
		end

		if not check_datatype_exists(item_datatype) then
			error(debug.traceback(`Invalid arr: item must be a valid datatype. Got id: "{item_datatype}"`))
		elseif not check_datatype_exists(length_datatype) then
			error(debug.traceback(`Invalid arr: length must be a valid datatype. Got id: "{length_datatype}"`))
		elseif not metadata.is_number[length_datatype] then
			error(debug.traceback(`Invalid arr: length must be a valid number datatype, got id: "{length_datatype}"`))
		elseif metadata.is_nilable[item_datatype] then
			error(debug.traceback(`Invalid arr: item must not be nilable. Consider using a map.`))
		end

		local static_item_size = metadata.static_size[item_datatype] :: number
		local static_length_size = metadata.static_size[length_datatype] :: number
		local literal_length_value = metadata.literal_value[length_datatype] :: number

		local case_literal_len_fully_static = literal_length_value and static_item_size and static_length_size
		local case_fully_static = static_item_size and static_length_size
		local case_static_item = static_item_size

		local arr_datatype = new_datatype() :: Datatype<{Item}>
		cache[hash] = arr_datatype

		local array_ser_no_realloc, array_ser_static, array_ser, array_des

		if case_literal_len_fully_static then
			local item_ser_static = metadata.ser_static[item_datatype]

			local array_static_size = literal_length_value * static_item_size
			metadata.static_size[arr_datatype] = array_static_size

			@native --dynamic_ncgen
			function array_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): (number)
				for item = 1, literal_length_value do
					item_ser_static(buff, byte_ptr, input[item])
					byte_ptr += static_item_size
				end

				return byte_ptr
			end

			@native --dynamic_ncgen
			function array_ser_static(buff: buffer, byte_ptr: number, input: any): ()
				for item = 1, literal_length_value do
					item_ser_static(buff, byte_ptr, input[item])
					byte_ptr += static_item_size
				end
			end

			@native --dynamic_ncgen
			function array_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
				local len = buffer.len(buff)

				local target_ptr = byte_ptr + array_static_size
				--stylua: ignore
				do -- alloc
					if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
				end

				for item = 1, literal_length_value do
					item_ser_static(buff, byte_ptr, input[item])
					byte_ptr += static_item_size
				end

				return byte_ptr, buff
			end
		elseif case_fully_static then
			local length_ser_static = metadata.ser_static[length_datatype]
			local item_ser_static = metadata.ser_static[item_datatype]

			@native --dynamic_ncgen
			function array_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
				local arr_len = #input

				local buff_len = buffer.len(buff)

				--stylua: ignore
				do -- alloc
					local increment = static_length_size + arr_len * static_item_size
					local target_ptr = byte_ptr + increment; if target_ptr > buff_len then local old_buff = buff; buff_len *= 2; while target_ptr > buff_len do buff_len *= 2 end; buff = buffer.create(buff_len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
				end

				length_ser_static(buff, byte_ptr, arr_len)
				byte_ptr += static_length_size

				for item = 1, arr_len do
					item_ser_static(buff, byte_ptr, input[item])
					byte_ptr += static_item_size
				end

				return byte_ptr, buff
			end
		elseif case_static_item then
			local length_ser = metadata.ser[length_datatype]
			local item_ser_static = metadata.ser_static[item_datatype]

			@native --dynamic_ncgen
			function array_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
				local arr_len = #input

				byte_ptr, buff = length_ser(buff, byte_ptr, arr_len)

				--stylua: ignore
				do
					local len = buffer.len(buff)

					local increment = arr_len * static_item_size

					local target_ptr = byte_ptr + increment; if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
				end

				for item = 1, arr_len do
					item_ser_static(buff, byte_ptr, input[item])
					byte_ptr += static_item_size
				end

				return byte_ptr, buff
			end
		else
			local length_ser = metadata.ser[length_datatype]
			local item_ser = metadata.ser[item_datatype]

			@native --dynamic_ncgen
			function array_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
				local arr_len = #input

				byte_ptr, buff = length_ser(buff, byte_ptr, arr_len)

				for item = 1, arr_len do
					byte_ptr, buff = item_ser(buff, byte_ptr, input[item])
				end

				return byte_ptr, buff
			end
		end

		do
			local des_length = metadata.des[length_datatype]
			local des_item = metadata.des[item_datatype]
	
			local table_create = table.create

			@native --dynamic_ncgen
			function array_des(buff: buffer, byte_ptr: number): (number, {Item})
				local arr_len
				byte_ptr, arr_len = des_length(buff, byte_ptr)
	
				local output: { any } = table_create(arr_len)
	
				for index = 1, arr_len do
					byte_ptr, output[index] = des_item(buff, byte_ptr)
				end
	
				return byte_ptr, output
			end
		end

		metadata.ser_no_realloc[arr_datatype] = array_ser_no_realloc
		metadata.ser_static[arr_datatype] = array_ser_static
		metadata.ser[arr_datatype] = array_ser
		metadata.des[arr_datatype] = array_des

		return arr_datatype
	end

datatypes.arr = arr end

do
	local cache = {} :: Set<string, Datatype<Set<any, any>>>

	local function map<Key, Value>(
		key_datatype: Datatype<Key>,
		value_datatype: Datatype<Value>,
		length_datatype: Datatype<number>?
	): Datatype<{[Key]: Value}>
		local length_datatype = length_datatype or datatypes.u16

		local hash = ordered_hash(key_datatype, value_datatype, length_datatype)

		do
			local cached = cache[hash]
			if cached ~= nil then return cached end
		end

		if not check_datatype_exists(key_datatype) then
			error(debug.traceback(`Invalid map: key must be a valid datatype. Got id: "{key_datatype}"`))
		elseif not check_datatype_exists(value_datatype) then
			error(debug.traceback(`Invalid map: value must be a valid datatype. Got id: "{value_datatype}"`))
		elseif not check_datatype_exists(length_datatype) then
			error(debug.traceback(`Invalid map: length must be a valid datatype. Got id: "{length_datatype}"`))
		elseif not metadata.is_number[length_datatype] then
			error(debug.traceback(`Invalid map: length must not be nilable. Got id: "{length_datatype}"`))
		end

		local key_static_size = metadata.static_size[key_datatype]
		local value_static_size = metadata.static_size[value_datatype]
		local length_static_size = metadata.static_size[length_datatype]
		local length_literal_value = metadata.literal_value[length_datatype]

		local case_literal_len_fully_static = key_static_size and value_static_size and length_static_size and length_literal_value
		local case_fully_static = key_static_size and value_static_size and length_static_size
		local case_static_pair = key_static_size and value_static_size
		local case_literal_len = length_static_size and length_literal_value
		local case_static_len = length_static_size

		local map_datatype = new_datatype()
		cache[hash] = map_datatype

		local map_ser_no_realloc, map_ser_static, map_ser, map_des

		if case_literal_len_fully_static then
			local pair_static_size = key_static_size + value_static_size
			local key_ser_static = metadata.ser_static[key_datatype]
			local value_ser_static = metadata.ser_static[value_datatype]

			local map_static_size = length_literal_value * pair_static_size
			metadata.static_size[map_datatype] = map_static_size

			@native --dynamic_ncgen
			function map_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): (number)
				local key, value
				for i = 1, length_literal_value do
					key, value = next(input, key)
					key_ser_static(buff, byte_ptr, key)
					byte_ptr += key_static_size
					value_ser_static(buff, byte_ptr, value)
					byte_ptr += value_static_size
				end
				return byte_ptr
			end

			@native --dynamic_ncgen
			function map_ser_static(buff: buffer, byte_ptr: number, input: any): ()
				local key, value
				for i = 1, length_literal_value do
					key, value = next(input, key)
					key_ser_static(buff, byte_ptr, key)
					byte_ptr += key_static_size
					value_ser_static(buff, byte_ptr, value)
					byte_ptr += value_static_size
				end
			end

			@native --dynamic_ncgen
			function map_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
				local len = buffer.len(buff)

				local target_ptr = byte_ptr + map_static_size
				--stylua: ignore
				do -- alloc
					if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
				end

				local key, value
				for i = 1, length_literal_value do
					key, value = next(input, key)
					key_ser_static(buff, byte_ptr, key)
					value_ser_static(buff, byte_ptr, value)
				end

				return byte_ptr, buff
			end
		elseif case_fully_static then
			local key_static_size = key_static_size
			local value_static_size = value_static_size
			local pair_static_size = key_static_size + value_static_size

			local key_ser_static = metadata.ser_static[key_datatype]
			local value_ser_static = metadata.ser_static[value_datatype]
			local length_ser_static = metadata.ser_static[length_datatype]

			@native --dynamic_ncgen
			function map_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
				local map_len = 0
				for _ in input do
					map_len += 1
				end

				local buff_len = buffer.len(buff)

				local target_ptr = byte_ptr + length_static_size + (map_len * pair_static_size); if target_ptr > buff_len then local old_buff = buff; buff_len *= 2; while target_ptr > buff_len do buff_len *= 2 end; buff = buffer.create(buff_len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
				--stylua: ignore
				do -- alloc
					if target_ptr > buff_len then local old_buff = buff; buff_len *= 2; while target_ptr > buff_len do buff_len *= 2 end; buff = buffer.create(buff_len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
				end

				length_ser_static(buff, byte_ptr, map_len)
				byte_ptr += length_static_size

				-- TODO: test `for i = 1, map_len do next(map, key)` is faster
				for key, value in input do
					key_ser_static(buff, byte_ptr, key)
					byte_ptr += value_static_size
					value_ser_static(buff, byte_ptr, value)
					byte_ptr += key_static_size
				end

				return target_ptr, buff
			end
		elseif case_static_pair then
			local pair_static_size = key_static_size + value_static_size

			local key_ser_static = metadata.ser_static[key_datatype]
			local value_ser_static = metadata.ser_static[value_datatype]
			local length_ser = metadata.ser[length_datatype]

			@native --dynamic_ncgen
			function map_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
				local map_len = 0
				for _ in input do
					map_len += 1
				end

				byte_ptr, buff = length_ser(buff, byte_ptr, map_len)

				local buff_len = buffer.len(buff)

				local target_ptr = byte_ptr + (map_len * pair_static_size); if target_ptr > buff_len then local old_buff = buff; buff_len *= 2; while target_ptr > buff_len do buff_len *= 2 end; buff = buffer.create(buff_len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
				--stylua: ignore
				do -- alloc
					if target_ptr > buff_len then local old_buff = buff; buff_len *= 2; while target_ptr > buff_len do buff_len *= 2 end; buff = buffer.create(buff_len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
				end

				-- TODO: test `for i = 1, map_len do next(map, key)` is faster
				for key, value in input do
					key_ser_static(buff, byte_ptr, key)
					byte_ptr += key_static_size
					value_ser_static(buff, byte_ptr, value)
					byte_ptr += value_static_size
				end

				return target_ptr, buff
			end
		elseif case_literal_len then
			local key_ser = metadata.ser[key_datatype]
			local value_ser = metadata.ser[value_datatype]

			@native --dynamic_ncgen
			function map_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
				local key, value
				for i = 1, length_literal_value do
					key, value = next(input, key)
					byte_ptr, buff = key_ser(buff, byte_ptr, key)
					byte_ptr, buff = value_ser(buff, byte_ptr, value)
				end

				return byte_ptr, buff
			end
		elseif case_static_len then
			local key_ser = metadata.ser[key_datatype]
			local value_ser = metadata.ser[value_datatype]
			local length_ser_static = metadata.ser_static[length_datatype]

			@native --dynamic_ncgen
			function map_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
				local length_ptr = byte_ptr
				byte_ptr += length_static_size

				local map_len = 0
				for key, value in input do
					map_len += 1

					byte_ptr, buff = key_ser(buff, byte_ptr, key)
					byte_ptr, buff = value_ser(buff, byte_ptr, value)
				end

				length_ser_static(buff, length_ptr, map_len)

				return byte_ptr, buff
			end
		else
			local key_ser = metadata.ser[key_datatype]
			local value_ser = metadata.ser[value_datatype]
			local length_ser = metadata.ser[length_datatype]

			@native --dynamic_ncgen
			function map_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
				local map_len = 0
				for _ in input do
					map_len += 1
				end

				byte_ptr, buff = length_ser(buff, byte_ptr, map_len)

				for key, value in input do
					byte_ptr, buff = key_ser(buff, byte_ptr, key)
					byte_ptr, buff = value_ser(buff, byte_ptr, value)
				end

				return byte_ptr, buff
			end
		end

		local key_des = metadata.des[key_datatype]
		local value_des = metadata.des[value_datatype]
		local length_des = metadata.des[length_datatype]

		@native --dynamic_ncgen
		function map_des(buff: buffer, byte_ptr: number): (number, {[Key]: Value})
			local map_len: number
			byte_ptr, map_len = length_des(buff, byte_ptr)

			local output = {}

			local key, value
			for _ = 1, map_len do
				byte_ptr, key = key_des(buff, byte_ptr)
				byte_ptr, value = value_des(buff, byte_ptr)
				output[key] = value
			end

			return byte_ptr, output
		end

		metadata.ser_no_realloc[map_datatype] = map_ser_no_realloc
		metadata.ser_static[map_datatype] = map_ser_static
		metadata.ser[map_datatype] = map_ser
		metadata.des[map_datatype] = map_des

		return map_datatype
	end
datatypes.map = map end

do
	local cache = {} :: Set<string, Datatype<{[string]: any}>>

	local function struct<Field>(template: Set<string, Datatype<Field>>): Datatype<Set<string, Field>>
		local static_keys = {} :: {string}
		local dynamic_keys = {} :: {string}
		local static_datatypes = {} :: {Datatype<Field>}
		local dynamic_datatypes = {} :: {Datatype<Field>}

		local struct_static_size = 0

		for key, datatype in template do
			if type(key) ~= "string" then
				error(debug.traceback(`struct field {key} is not a string.`))
			end

			if not check_datatype_exists(datatype) then
				error(debug.traceback(`struct field "{key}" = {datatype}, which is not a valid datatype.`))
			end

			local field_static_size = metadata.static_size[datatype]

			if field_static_size ~= nil then
				table.insert(static_keys, key)
				table.insert(static_datatypes, datatype)
				struct_static_size += field_static_size
			else
				table.insert(dynamic_keys, key)
				table.insert(dynamic_datatypes, datatype)
			end
		end

		local hashed = ordered_hash(
			table.unpack(static_keys),
			table.unpack(static_datatypes),
			table.unpack(dynamic_keys),
			table.unpack(dynamic_datatypes)
		)
		do
			local cached = cache[hashed]
			if cached ~= nil then return cached end
		end

		local num_static_keys = #static_keys
		local num_dynamic_keys = #dynamic_keys

		local static_eh = num_static_keys >= 1
		local dynamic_eh = num_dynamic_keys >= 1

		local case_fully_static = static_eh and not dynamic_eh
		local case_mixed = static_eh and dynamic_eh

		local static_fields_ser = table.create(num_static_keys) :: { SerNoRealloc }
		local static_fields_des = table.create(num_static_keys) :: { Des }
		local dynamic_fields_ser = table.create(num_dynamic_keys) :: { Ser }
		local dynamic_fields_des = table.create(num_dynamic_keys) :: {Des}

		-- cloning template for a more stable copy. On deserialization holy calls table.clone() on the template, which
		-- makes populating string keys significantly faster.
		local clone_template = table.clone(template)

		for index, datatype in static_datatypes do
			static_fields_ser[index] = metadata.ser_no_realloc[datatype]
			static_fields_des[index] = metadata.des[datatype]
		end
		for index, datatype in dynamic_datatypes do
			dynamic_fields_ser[index] = metadata.ser[datatype]
			dynamic_fields_des[index] = metadata.des[datatype]
		end

		local struct_datatype = new_datatype(if case_fully_static then struct_static_size else nil)
		cache[hashed] = struct_datatype

		local struct_ser_no_realloc, struct_ser_static, struct_ser, struct_des

		--[=/=/=/=/=/=/=/=/=/=[
		-- FORGIVE ME FATHER, FOR I HAVE SINNED.
		-- FOR A NOBLE CAUSE, I HAVE DONE THAT WHICH PRESCRIBES BRAVERY VERY FEW POSSESS.
		-- I PRAY YOU MAY FORGIVE ME.
		-- there is good reason nobody else has done this
		-- i'm not everybody else tho :3
		-- https://open.spotify.com/track/1b9K8zcencFmQl68Oot9DS
		--]=/=/=/=/=/=/=/=/=/=]
		if case_fully_static then
			local field_a_name = static_keys[1]
			local field_a_ser = static_fields_ser[1]
			local field_a_des = static_fields_des[1]
			local field_b_name = static_keys[2]
			local field_b_ser = static_fields_ser[2]
			local field_b_des = static_fields_des[2]
			local field_c_name = static_keys[3]
			local field_c_ser = static_fields_ser[3]
			local field_c_des = static_fields_des[3]
			local field_d_name = static_keys[4]
			local field_d_ser = static_fields_ser[4]
			local field_d_des = static_fields_des[4]
			local field_e_name = static_keys[5]
			local field_e_ser = static_fields_ser[5]
			local field_e_des = static_fields_des[5]
			local field_f_name = static_keys[6]
			local field_f_ser = static_fields_ser[6]
			local field_f_des = static_fields_des[6]
			local field_g_name = static_keys[7]
			local field_g_ser = static_fields_ser[7]
			local field_g_des = static_fields_des[7]
			local field_h_name = static_keys[8]
			local field_h_ser = static_fields_ser[8]
			local field_h_des = static_fields_des[8]

			if num_static_keys == 1 then
				@native --dynamic_ncgen
				function struct_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): (number)
					byte_ptr = field_a_ser(buff, byte_ptr, input[field_a_name])
					return byte_ptr
				end
				@native --dynamic_ncgen
				function struct_ser_static(buff: buffer, byte_ptr: number, input: any): ()
					byte_ptr = field_a_ser(buff, byte_ptr, input[field_a_name])
				end
				@native --dynamic_ncgen
				function struct_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
					local len = buffer.len(buff)

					local target_ptr = byte_ptr + struct_static_size
					--stylua: ignore
					do -- alloc
						if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
					end

					byte_ptr = field_a_ser(buff, byte_ptr, input[field_a_name])
					return byte_ptr, buff
				end
				@native --dynamic_ncgen
				function struct_des(buff: buffer, byte_ptr: number): (number, any)
					local output = table.clone(clone_template)
					byte_ptr, output[field_a_name] = field_a_des(buff, byte_ptr)
					return byte_ptr, output
				end
			elseif num_static_keys == 2 then
				@native --dynamic_ncgen
				function struct_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): (number)
					byte_ptr = field_a_ser(buff, byte_ptr, input[field_a_name])
					byte_ptr = field_b_ser(buff, byte_ptr, input[field_b_name])
					return byte_ptr
				end
				@native --dynamic_ncgen
				function struct_ser_static(buff: buffer, byte_ptr: number, input: any): ()
					byte_ptr = field_a_ser(buff, byte_ptr, input[field_a_name])
					byte_ptr = field_b_ser(buff, byte_ptr, input[field_b_name])
				end
				@native --dynamic_ncgen
				function struct_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
					local len = buffer.len(buff)
					local target_ptr = byte_ptr + struct_static_size
					--stylua: ignore
					do -- alloc
						if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
					end
					byte_ptr = field_a_ser(buff, byte_ptr, input[field_a_name])
					byte_ptr = field_b_ser(buff, byte_ptr, input[field_b_name])
					return byte_ptr, buff
				end
				@native --dynamic_ncgen
				function struct_des(buff: buffer, byte_ptr: number): (number, any)
					local output = table.clone(clone_template)
					byte_ptr, output[field_a_name] = field_a_des(buff, byte_ptr)
					byte_ptr, output[field_b_name] = field_b_des(buff, byte_ptr)
					return byte_ptr, output
				end
			elseif num_static_keys == 3 then
				@native --dynamic_ncgen
				function struct_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): (number)
					byte_ptr = field_a_ser(buff, byte_ptr, input[field_a_name])
					byte_ptr = field_b_ser(buff, byte_ptr, input[field_b_name])
					byte_ptr = field_c_ser(buff, byte_ptr, input[field_c_name])
					return byte_ptr
				end
				@native --dynamic_ncgen
				function struct_ser_static(buff: buffer, byte_ptr: number, input: any): ()
					byte_ptr = field_a_ser(buff, byte_ptr, input[field_a_name])
					byte_ptr = field_b_ser(buff, byte_ptr, input[field_b_name])
					byte_ptr = field_c_ser(buff, byte_ptr, input[field_c_name])
				end
				@native --dynamic_ncgen
				function struct_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
					local len = buffer.len(buff)
					local target_ptr = byte_ptr + struct_static_size
					--stylua: ignore
					do -- alloc
						if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
					end
					byte_ptr = field_a_ser(buff, byte_ptr, input[field_a_name])
					byte_ptr = field_b_ser(buff, byte_ptr, input[field_b_name])
					byte_ptr = field_c_ser(buff, byte_ptr, input[field_c_name])
					return byte_ptr, buff
				end
				@native --dynamic_ncgen
				function struct_des(buff: buffer, byte_ptr: number): (number, any)
					local output = table.clone(clone_template)
					byte_ptr, output[field_a_name] = field_a_des(buff, byte_ptr)
					byte_ptr, output[field_b_name] = field_b_des(buff, byte_ptr)
					byte_ptr, output[field_c_name] = field_c_des(buff, byte_ptr)
					return byte_ptr, output
				end
			elseif num_static_keys == 4 then
				@native --dynamic_ncgen
				function struct_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): (number)
					byte_ptr = field_a_ser(buff, byte_ptr, input[field_a_name])
					byte_ptr = field_b_ser(buff, byte_ptr, input[field_b_name])
					byte_ptr = field_c_ser(buff, byte_ptr, input[field_c_name])
					byte_ptr = field_d_ser(buff, byte_ptr, input[field_d_name])
					return byte_ptr
				end
				@native --dynamic_ncgen
				function struct_ser_static(buff: buffer, byte_ptr: number, input: any): ()
					byte_ptr = field_a_ser(buff, byte_ptr, input[field_a_name])
					byte_ptr = field_b_ser(buff, byte_ptr, input[field_b_name])
					byte_ptr = field_c_ser(buff, byte_ptr, input[field_c_name])
					byte_ptr = field_d_ser(buff, byte_ptr, input[field_d_name])
				end
				@native --dynamic_ncgen
				function struct_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
					local len = buffer.len(buff)
					local target_ptr = byte_ptr + struct_static_size
					--stylua: ignore
					do -- alloc
						if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
					end
					byte_ptr = field_a_ser(buff, byte_ptr, input[field_a_name])
					byte_ptr = field_b_ser(buff, byte_ptr, input[field_b_name])
					byte_ptr = field_c_ser(buff, byte_ptr, input[field_c_name])
					byte_ptr = field_d_ser(buff, byte_ptr, input[field_d_name])
					return byte_ptr, buff
				end
				@native --dynamic_ncgen
				function struct_des(buff: buffer, byte_ptr: number): (number, any)
					local output = table.clone(clone_template)
					byte_ptr, output[field_a_name] = field_a_des(buff, byte_ptr)
					byte_ptr, output[field_b_name] = field_b_des(buff, byte_ptr)
					byte_ptr, output[field_c_name] = field_c_des(buff, byte_ptr)
					byte_ptr, output[field_d_name] = field_d_des(buff, byte_ptr)
					return byte_ptr, output
				end
			elseif num_static_keys == 5 then
				@native --dynamic_ncgen
				function struct_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): (number)
					byte_ptr = field_a_ser(buff, byte_ptr, input[field_a_name])
					byte_ptr = field_b_ser(buff, byte_ptr, input[field_b_name])
					byte_ptr = field_c_ser(buff, byte_ptr, input[field_c_name])
					byte_ptr = field_d_ser(buff, byte_ptr, input[field_d_name])
					byte_ptr = field_e_ser(buff, byte_ptr, input[field_e_name])
					return byte_ptr
				end
				@native --dynamic_ncgen
				function struct_ser_static(buff: buffer, byte_ptr: number, input: any): ()
					byte_ptr = field_a_ser(buff, byte_ptr, input[field_a_name])
					byte_ptr = field_b_ser(buff, byte_ptr, input[field_b_name])
					byte_ptr = field_c_ser(buff, byte_ptr, input[field_c_name])
					byte_ptr = field_d_ser(buff, byte_ptr, input[field_d_name])
					byte_ptr = field_e_ser(buff, byte_ptr, input[field_e_name])
				end
				@native --dynamic_ncgen
				function struct_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
					local len = buffer.len(buff)
					local target_ptr = byte_ptr + struct_static_size
					--stylua: ignore
					do -- alloc
						if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
					end
					byte_ptr = field_a_ser(buff, byte_ptr, input[field_a_name])
					byte_ptr = field_b_ser(buff, byte_ptr, input[field_b_name])
					byte_ptr = field_c_ser(buff, byte_ptr, input[field_c_name])
					byte_ptr = field_d_ser(buff, byte_ptr, input[field_d_name])
					byte_ptr = field_e_ser(buff, byte_ptr, input[field_e_name])
					return byte_ptr, buff
				end
				@native --dynamic_ncgen
				function struct_des(buff: buffer, byte_ptr: number): (number, any)
					local output = table.clone(clone_template)
					byte_ptr, output[field_a_name] = field_a_des(buff, byte_ptr)
					byte_ptr, output[field_b_name] = field_b_des(buff, byte_ptr)
					byte_ptr, output[field_c_name] = field_c_des(buff, byte_ptr)
					byte_ptr, output[field_d_name] = field_d_des(buff, byte_ptr)
					byte_ptr, output[field_e_name] = field_e_des(buff, byte_ptr)
					return byte_ptr, output
				end
			elseif num_static_keys == 6 then
				@native --dynamic_ncgen
				function struct_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): (number)
					byte_ptr = field_a_ser(buff, byte_ptr, input[field_a_name])
					byte_ptr = field_b_ser(buff, byte_ptr, input[field_b_name])
					byte_ptr = field_c_ser(buff, byte_ptr, input[field_c_name])
					byte_ptr = field_d_ser(buff, byte_ptr, input[field_d_name])
					byte_ptr = field_e_ser(buff, byte_ptr, input[field_e_name])
					byte_ptr = field_f_ser(buff, byte_ptr, input[field_f_name])
					return byte_ptr
				end
				@native --dynamic_ncgen
				function struct_ser_static(buff: buffer, byte_ptr: number, input: any): ()
					byte_ptr = field_a_ser(buff, byte_ptr, input[field_a_name])
					byte_ptr = field_b_ser(buff, byte_ptr, input[field_b_name])
					byte_ptr = field_c_ser(buff, byte_ptr, input[field_c_name])
					byte_ptr = field_d_ser(buff, byte_ptr, input[field_d_name])
					byte_ptr = field_e_ser(buff, byte_ptr, input[field_e_name])
					byte_ptr = field_f_ser(buff, byte_ptr, input[field_f_name])
				end
				@native --dynamic_ncgen
				function struct_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
					local len = buffer.len(buff)
					local target_ptr = byte_ptr + struct_static_size
					--stylua: ignore
					do -- alloc
						if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
					end
					byte_ptr = field_a_ser(buff, byte_ptr, input[field_a_name])
					byte_ptr = field_b_ser(buff, byte_ptr, input[field_b_name])
					byte_ptr = field_c_ser(buff, byte_ptr, input[field_c_name])
					byte_ptr = field_d_ser(buff, byte_ptr, input[field_d_name])
					byte_ptr = field_e_ser(buff, byte_ptr, input[field_e_name])
					byte_ptr = field_f_ser(buff, byte_ptr, input[field_f_name])
					return byte_ptr, buff
				end
				@native --dynamic_ncgen
				function struct_des(buff: buffer, byte_ptr: number): (number, any)
					local output = table.clone(clone_template)
					byte_ptr, output[field_a_name] = field_a_des(buff, byte_ptr)
					byte_ptr, output[field_b_name] = field_b_des(buff, byte_ptr)
					byte_ptr, output[field_c_name] = field_c_des(buff, byte_ptr)
					byte_ptr, output[field_d_name] = field_d_des(buff, byte_ptr)
					byte_ptr, output[field_e_name] = field_e_des(buff, byte_ptr)
					byte_ptr, output[field_f_name] = field_f_des(buff, byte_ptr)
					return byte_ptr, output
				end
			elseif num_static_keys == 7 then
				@native --dynamic_ncgen
				function struct_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): (number)
					byte_ptr = field_a_ser(buff, byte_ptr, input[field_a_name])
					byte_ptr = field_b_ser(buff, byte_ptr, input[field_b_name])
					byte_ptr = field_c_ser(buff, byte_ptr, input[field_c_name])
					byte_ptr = field_d_ser(buff, byte_ptr, input[field_d_name])
					byte_ptr = field_e_ser(buff, byte_ptr, input[field_e_name])
					byte_ptr = field_f_ser(buff, byte_ptr, input[field_f_name])
					byte_ptr = field_g_ser(buff, byte_ptr, input[field_g_name])
					return byte_ptr
				end
				@native --dynamic_ncgen
				function struct_ser_static(buff: buffer, byte_ptr: number, input: any): ()
					byte_ptr = field_a_ser(buff, byte_ptr, input[field_a_name])
					byte_ptr = field_b_ser(buff, byte_ptr, input[field_b_name])
					byte_ptr = field_c_ser(buff, byte_ptr, input[field_c_name])
					byte_ptr = field_d_ser(buff, byte_ptr, input[field_d_name])
					byte_ptr = field_e_ser(buff, byte_ptr, input[field_e_name])
					byte_ptr = field_f_ser(buff, byte_ptr, input[field_f_name])
					byte_ptr = field_g_ser(buff, byte_ptr, input[field_g_name])
				end
				@native --dynamic_ncgen
				function struct_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
					local len = buffer.len(buff)
					local target_ptr = byte_ptr + struct_static_size
					--stylua: ignore
					do -- alloc
						if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
					end
					byte_ptr = field_a_ser(buff, byte_ptr, input[field_a_name])
					byte_ptr = field_b_ser(buff, byte_ptr, input[field_b_name])
					byte_ptr = field_c_ser(buff, byte_ptr, input[field_c_name])
					byte_ptr = field_d_ser(buff, byte_ptr, input[field_d_name])
					byte_ptr = field_e_ser(buff, byte_ptr, input[field_e_name])
					byte_ptr = field_f_ser(buff, byte_ptr, input[field_f_name])
					byte_ptr = field_g_ser(buff, byte_ptr, input[field_g_name])
					return byte_ptr, buff
				end
				@native --dynamic_ncgen
				function struct_des(buff: buffer, byte_ptr: number): (number, any)
					local output = table.clone(clone_template)
					byte_ptr, output[field_a_name] = field_a_des(buff, byte_ptr)
					byte_ptr, output[field_b_name] = field_b_des(buff, byte_ptr)
					byte_ptr, output[field_c_name] = field_c_des(buff, byte_ptr)
					byte_ptr, output[field_d_name] = field_d_des(buff, byte_ptr)
					byte_ptr, output[field_e_name] = field_e_des(buff, byte_ptr)
					byte_ptr, output[field_f_name] = field_f_des(buff, byte_ptr)
					byte_ptr, output[field_g_name] = field_g_des(buff, byte_ptr)
					return byte_ptr, output
				end
			elseif num_static_keys == 8 then
				@native --dynamic_ncgen
				function struct_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): (number)
					byte_ptr = field_a_ser(buff, byte_ptr, input[field_a_name])
					byte_ptr = field_b_ser(buff, byte_ptr, input[field_b_name])
					byte_ptr = field_c_ser(buff, byte_ptr, input[field_c_name])
					byte_ptr = field_d_ser(buff, byte_ptr, input[field_d_name])
					byte_ptr = field_e_ser(buff, byte_ptr, input[field_e_name])
					byte_ptr = field_f_ser(buff, byte_ptr, input[field_f_name])
					byte_ptr = field_g_ser(buff, byte_ptr, input[field_g_name])
					byte_ptr = field_h_ser(buff, byte_ptr, input[field_h_name])
					return byte_ptr
				end
				@native --dynamic_ncgen
				function struct_ser_static(buff: buffer, byte_ptr: number, input: any): ()
					byte_ptr = field_a_ser(buff, byte_ptr, input[field_a_name])
					byte_ptr = field_b_ser(buff, byte_ptr, input[field_b_name])
					byte_ptr = field_c_ser(buff, byte_ptr, input[field_c_name])
					byte_ptr = field_d_ser(buff, byte_ptr, input[field_d_name])
					byte_ptr = field_e_ser(buff, byte_ptr, input[field_e_name])
					byte_ptr = field_f_ser(buff, byte_ptr, input[field_f_name])
					byte_ptr = field_g_ser(buff, byte_ptr, input[field_g_name])
					byte_ptr = field_h_ser(buff, byte_ptr, input[field_h_name])
				end
				@native --dynamic_ncgen
				function struct_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
					local len = buffer.len(buff)
					local target_ptr = byte_ptr + struct_static_size
					--stylua: ignore
					do -- alloc
						if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
					end
					byte_ptr = field_a_ser(buff, byte_ptr, input[field_a_name])
					byte_ptr = field_b_ser(buff, byte_ptr, input[field_b_name])
					byte_ptr = field_c_ser(buff, byte_ptr, input[field_c_name])
					byte_ptr = field_d_ser(buff, byte_ptr, input[field_d_name])
					byte_ptr = field_e_ser(buff, byte_ptr, input[field_e_name])
					byte_ptr = field_f_ser(buff, byte_ptr, input[field_f_name])
					byte_ptr = field_g_ser(buff, byte_ptr, input[field_g_name])
					byte_ptr = field_h_ser(buff, byte_ptr, input[field_h_name])
					return byte_ptr, buff
				end
				@native --dynamic_ncgen
				function struct_des(buff: buffer, byte_ptr: number): (number, any)
					local output = table.clone(clone_template)
					byte_ptr, output[field_a_name] = field_a_des(buff, byte_ptr)
					byte_ptr, output[field_b_name] = field_b_des(buff, byte_ptr)
					byte_ptr, output[field_c_name] = field_c_des(buff, byte_ptr)
					byte_ptr, output[field_d_name] = field_d_des(buff, byte_ptr)
					byte_ptr, output[field_e_name] = field_e_des(buff, byte_ptr)
					byte_ptr, output[field_f_name] = field_f_des(buff, byte_ptr)
					byte_ptr, output[field_g_name] = field_g_des(buff, byte_ptr)
					byte_ptr, output[field_h_name] = field_h_des(buff, byte_ptr)
					return byte_ptr, output
				end
			else
				@native --dynamic_ncgen
				function struct_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): (number)
					for index = 1, num_static_keys do
						local field_name = static_keys[index]

						local field_ser = static_fields_ser[index]

						byte_ptr = field_ser(buff, byte_ptr, input[field_name])
					end

					return byte_ptr
				end
				@native --dynamic_ncgen
				function struct_ser_static(buff: buffer, byte_ptr: number, input: any): ()
					for index = 1, num_static_keys do
						local field_name = static_keys[index]

						local field_ser = static_fields_ser[index]

						byte_ptr = field_ser(buff, byte_ptr, input[field_name])
					end
				end
				@native --dynamic_ncgen
				function struct_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
					local len = buffer.len(buff)

					local target_ptr = byte_ptr + struct_static_size
					--stylua: ignore
					do -- alloc
						if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
					end
					
					for index = 1, num_static_keys do
						local field_name = static_keys[index]

						local field_ser = static_fields_ser[index]

						byte_ptr = field_ser(buff, byte_ptr, input[field_name])
					end

					return byte_ptr, buff
				end
				@native --dynamic_ncgen
				function struct_des(buff: buffer, byte_ptr: number): (number, any)
					local output = table.clone(clone_template)

					for index = 1, num_static_keys do
						local field_name = static_keys[index]

						local field_des = static_fields_des[index]

						byte_ptr, output[field_name] = field_des(buff, byte_ptr)
					end

					return byte_ptr, output
				end
			end
		elseif case_mixed then
			local static_field_a_name = static_keys[1]
			local static_field_a_ser = static_fields_ser[1]
			local static_field_a_des = static_fields_des[1]
			local static_field_b_name = static_keys[2]
			local static_field_b_ser = static_fields_ser[2]
			local static_field_b_des = static_fields_des[2]
			local static_field_c_name = static_keys[3]
			local static_field_c_ser = static_fields_ser[3]
			local static_field_c_des = static_fields_des[3]
			local static_field_d_name = static_keys[4]
			local static_field_d_ser = static_fields_ser[4]
			local static_field_d_des = static_fields_des[4]
			local static_field_e_name = static_keys[5]
			local static_field_e_ser = static_fields_ser[5]
			local static_field_e_des = static_fields_des[5]
			local static_field_f_name = static_keys[6]
			local static_field_f_ser = static_fields_ser[6]
			local static_field_f_des = static_fields_des[6]
			local static_field_g_name = static_keys[7]
			local static_field_g_ser = static_fields_ser[7]
			local static_field_g_des = static_fields_des[7]
			local static_field_h_name = static_keys[8]
			local static_field_h_ser = static_fields_ser[8]
			local static_field_h_des = static_fields_des[8]

			local dynamic_field_a_name = dynamic_keys[1]
			local dynamic_field_a_ser = dynamic_fields_ser[1]
			local dynamic_field_a_des = dynamic_fields_des[1]
			local dynamic_field_b_name = dynamic_keys[2]
			local dynamic_field_b_ser = dynamic_fields_ser[2]
			local dynamic_field_b_des = dynamic_fields_des[2]
			local dynamic_field_c_name = dynamic_keys[3]
			local dynamic_field_c_ser = dynamic_fields_ser[3]
			local dynamic_field_c_des = dynamic_fields_des[3]
			local dynamic_field_d_name = dynamic_keys[4]
			local dynamic_field_d_ser = dynamic_fields_ser[4]
			local dynamic_field_d_des = dynamic_fields_des[4]
			local dynamic_field_e_name = dynamic_keys[5]
			local dynamic_field_e_ser = dynamic_fields_ser[5]
			local dynamic_field_e_des = dynamic_fields_des[5]
			local dynamic_field_f_name = dynamic_keys[6]
			local dynamic_field_f_ser = dynamic_fields_ser[6]
			local dynamic_field_f_des = dynamic_fields_des[6]
			local dynamic_field_g_name = dynamic_keys[7]
			local dynamic_field_g_ser = dynamic_fields_ser[7]
			local dynamic_field_g_des = dynamic_fields_des[7]
			local dynamic_field_h_name = dynamic_keys[8]
			local dynamic_field_h_ser = dynamic_fields_ser[8]
			local dynamic_field_h_des = dynamic_fields_des[8]

			local static_portion_ser_static
			local static_portion_decode
			if num_static_keys == 1 then
				@native --dynamic_ncgen
				function static_portion_ser_static(buff: buffer, byte_ptr: number, input: any): ()
					byte_ptr = static_field_a_ser(buff, byte_ptr, input[static_field_a_name])
				end
				@native --dynamic_ncgen
				function static_portion_decode(buff: buffer, byte_ptr: number, output: any): (number)
					byte_ptr, output[static_field_a_name] = static_field_a_des(buff, byte_ptr)
					return byte_ptr
				end
			elseif num_static_keys == 2 then
				@native --dynamic_ncgen
				function static_portion_ser_static(buff: buffer, byte_ptr: number, input: any): ()
					byte_ptr = static_field_a_ser(buff, byte_ptr, input[static_field_a_name])
					byte_ptr = static_field_b_ser(buff, byte_ptr, input[static_field_b_name])
				end
				@native --dynamic_ncgen
				function static_portion_decode(buff: buffer, byte_ptr: number, output: any): (number)
					byte_ptr, output[static_field_a_name] = static_field_a_des(buff, byte_ptr)
					byte_ptr, output[static_field_b_name] = static_field_b_des(buff, byte_ptr)
					return byte_ptr
				end
			elseif num_static_keys == 3 then
				@native --dynamic_ncgen
				function static_portion_ser_static(buff: buffer, byte_ptr: number, input: any): ()
					byte_ptr = static_field_a_ser(buff, byte_ptr, input[static_field_a_name])
					byte_ptr = static_field_b_ser(buff, byte_ptr, input[static_field_b_name])
					byte_ptr = static_field_c_ser(buff, byte_ptr, input[static_field_c_name])
				end
				@native --dynamic_ncgen
				function static_portion_decode(buff: buffer, byte_ptr: number, output: any): (number)
					byte_ptr, output[static_field_a_name] = static_field_a_des(buff, byte_ptr)
					byte_ptr, output[static_field_b_name] = static_field_b_des(buff, byte_ptr)
					byte_ptr, output[static_field_c_name] = static_field_c_des(buff, byte_ptr)
					return byte_ptr
				end
			elseif num_static_keys == 4 then
				@native --dynamic_ncgen
				function static_portion_ser_static(buff: buffer, byte_ptr: number, input: any): ()
					byte_ptr = static_field_a_ser(buff, byte_ptr, input[static_field_a_name])
					byte_ptr = static_field_b_ser(buff, byte_ptr, input[static_field_b_name])
					byte_ptr = static_field_c_ser(buff, byte_ptr, input[static_field_c_name])
					byte_ptr = static_field_d_ser(buff, byte_ptr, input[static_field_d_name])
				end
				@native --dynamic_ncgen
				function static_portion_decode(buff: buffer, byte_ptr: number, output: any): (number)
					byte_ptr, output[static_field_a_name] = static_field_a_des(buff, byte_ptr)
					byte_ptr, output[static_field_b_name] = static_field_b_des(buff, byte_ptr)
					byte_ptr, output[static_field_c_name] = static_field_c_des(buff, byte_ptr)
					byte_ptr, output[static_field_d_name] = static_field_d_des(buff, byte_ptr)
					return byte_ptr
				end
			elseif num_static_keys == 5 then
				@native --dynamic_ncgen
				function static_portion_ser_static(buff: buffer, byte_ptr: number, input: any): ()
					byte_ptr = static_field_a_ser(buff, byte_ptr, input[static_field_a_name])
					byte_ptr = static_field_b_ser(buff, byte_ptr, input[static_field_b_name])
					byte_ptr = static_field_c_ser(buff, byte_ptr, input[static_field_c_name])
					byte_ptr = static_field_d_ser(buff, byte_ptr, input[static_field_d_name])
					byte_ptr = static_field_e_ser(buff, byte_ptr, input[static_field_e_name])
				end
				@native --dynamic_ncgen
				function static_portion_decode(buff: buffer, byte_ptr: number, output: any): (number)
					byte_ptr, output[static_field_a_name] = static_field_a_des(buff, byte_ptr)
					byte_ptr, output[static_field_b_name] = static_field_b_des(buff, byte_ptr)
					byte_ptr, output[static_field_c_name] = static_field_c_des(buff, byte_ptr)
					byte_ptr, output[static_field_d_name] = static_field_d_des(buff, byte_ptr)
					byte_ptr, output[static_field_e_name] = static_field_e_des(buff, byte_ptr)
					return byte_ptr
				end
			elseif num_static_keys == 6 then
				@native --dynamic_ncgen
				function static_portion_ser_static(buff: buffer, byte_ptr: number, input: any): ()
					byte_ptr = static_field_a_ser(buff, byte_ptr, input[static_field_a_name])
					byte_ptr = static_field_b_ser(buff, byte_ptr, input[static_field_b_name])
					byte_ptr = static_field_c_ser(buff, byte_ptr, input[static_field_c_name])
					byte_ptr = static_field_d_ser(buff, byte_ptr, input[static_field_d_name])
					byte_ptr = static_field_e_ser(buff, byte_ptr, input[static_field_e_name])
					byte_ptr = static_field_f_ser(buff, byte_ptr, input[static_field_f_name])
				end
				@native --dynamic_ncgen
				function static_portion_decode(buff: buffer, byte_ptr: number, output: any): (number)
					byte_ptr, output[static_field_a_name] = static_field_a_des(buff, byte_ptr)
					byte_ptr, output[static_field_b_name] = static_field_b_des(buff, byte_ptr)
					byte_ptr, output[static_field_c_name] = static_field_c_des(buff, byte_ptr)
					byte_ptr, output[static_field_d_name] = static_field_d_des(buff, byte_ptr)
					byte_ptr, output[static_field_e_name] = static_field_e_des(buff, byte_ptr)
					byte_ptr, output[static_field_f_name] = static_field_f_des(buff, byte_ptr)
					return byte_ptr
				end
			elseif num_static_keys == 7 then
				@native --dynamic_ncgen
				function static_portion_ser_static(buff: buffer, byte_ptr: number, input: any): ()
					byte_ptr = static_field_a_ser(buff, byte_ptr, input[static_field_a_name])
					byte_ptr = static_field_b_ser(buff, byte_ptr, input[static_field_b_name])
					byte_ptr = static_field_c_ser(buff, byte_ptr, input[static_field_c_name])
					byte_ptr = static_field_d_ser(buff, byte_ptr, input[static_field_d_name])
					byte_ptr = static_field_e_ser(buff, byte_ptr, input[static_field_e_name])
					byte_ptr = static_field_f_ser(buff, byte_ptr, input[static_field_f_name])
					byte_ptr = static_field_g_ser(buff, byte_ptr, input[static_field_g_name])
				end
				@native --dynamic_ncgen
				function static_portion_decode(buff: buffer, byte_ptr: number, output: any): (number)
					byte_ptr, output[static_field_a_name] = static_field_a_des(buff, byte_ptr)
					byte_ptr, output[static_field_b_name] = static_field_b_des(buff, byte_ptr)
					byte_ptr, output[static_field_c_name] = static_field_c_des(buff, byte_ptr)
					byte_ptr, output[static_field_d_name] = static_field_d_des(buff, byte_ptr)
					byte_ptr, output[static_field_e_name] = static_field_e_des(buff, byte_ptr)
					byte_ptr, output[static_field_f_name] = static_field_f_des(buff, byte_ptr)
					byte_ptr, output[static_field_g_name] = static_field_g_des(buff, byte_ptr)
					return byte_ptr
				end
			elseif num_static_keys == 8 then
				@native --dynamic_ncgen
				function static_portion_ser_static(buff: buffer, byte_ptr: number, input: any): ()
					byte_ptr = static_field_a_ser(buff, byte_ptr, input[static_field_a_name])
					byte_ptr = static_field_b_ser(buff, byte_ptr, input[static_field_b_name])
					byte_ptr = static_field_c_ser(buff, byte_ptr, input[static_field_c_name])
					byte_ptr = static_field_d_ser(buff, byte_ptr, input[static_field_d_name])
					byte_ptr = static_field_e_ser(buff, byte_ptr, input[static_field_e_name])
					byte_ptr = static_field_f_ser(buff, byte_ptr, input[static_field_f_name])
					byte_ptr = static_field_g_ser(buff, byte_ptr, input[static_field_g_name])
					byte_ptr = static_field_h_ser(buff, byte_ptr, input[static_field_h_name])
				end
				@native --dynamic_ncgen
				function static_portion_decode(buff: buffer, byte_ptr: number, output: any): (number)
					byte_ptr, output[static_field_a_name] = static_field_a_des(buff, byte_ptr)
					byte_ptr, output[static_field_b_name] = static_field_b_des(buff, byte_ptr)
					byte_ptr, output[static_field_c_name] = static_field_c_des(buff, byte_ptr)
					byte_ptr, output[static_field_d_name] = static_field_d_des(buff, byte_ptr)
					byte_ptr, output[static_field_e_name] = static_field_e_des(buff, byte_ptr)
					byte_ptr, output[static_field_f_name] = static_field_f_des(buff, byte_ptr)
					byte_ptr, output[static_field_g_name] = static_field_g_des(buff, byte_ptr)
					byte_ptr, output[static_field_h_name] = static_field_h_des(buff, byte_ptr)
					return byte_ptr
				end
			else
				@native --dynamic_ncgen
				function static_portion_ser_static(buff: buffer, byte_ptr: number, input: any): ()
					for index = 1, num_static_keys do
						local field_name = static_keys[index]

						local field_ser = static_fields_ser[index]

						byte_ptr = field_ser(buff, byte_ptr, input[field_name])
					end
				end
				@native --dynamic_ncgen
				function static_portion_decode(buff: buffer, byte_ptr: number, output: any): (number)
					for index = 1, num_static_keys do
						local key_name = static_keys[index]

						local key_des = static_fields_des[index]

						byte_ptr, output[key_name] = key_des(buff, byte_ptr)
					end
					return byte_ptr
				end
			end

			local dynamic_portion_ser
			local dynamic_portion_decode
			if num_dynamic_keys == 1 then
				@native --dynamic_ncgen
				function dynamic_portion_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
					byte_ptr, buff = dynamic_field_a_ser(buff, byte_ptr, input[dynamic_field_a_name])
					return byte_ptr, buff
				end
				@native --dynamic_ncgen
				function dynamic_portion_decode(buff: buffer, byte_ptr: number, output: any): (number)
					byte_ptr, output[dynamic_field_a_name] = dynamic_field_a_des(buff, byte_ptr)
					return byte_ptr
				end
			elseif num_dynamic_keys == 2 then
				@native --dynamic_ncgen
				function dynamic_portion_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
					byte_ptr, buff = dynamic_field_a_ser(buff, byte_ptr, input[dynamic_field_a_name])
					byte_ptr, buff = dynamic_field_b_ser(buff, byte_ptr, input[dynamic_field_b_name])
					return byte_ptr, buff
				end
				@native --dynamic_ncgen
				function dynamic_portion_decode(buff: buffer, byte_ptr: number, output: any): (number)
					byte_ptr, output[dynamic_field_a_name] = dynamic_field_a_des(buff, byte_ptr)
					byte_ptr, output[dynamic_field_b_name] = dynamic_field_b_des(buff, byte_ptr)
					return byte_ptr
				end
			elseif num_dynamic_keys == 3 then
				@native --dynamic_ncgen
				function dynamic_portion_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
					byte_ptr, buff = dynamic_field_a_ser(buff, byte_ptr, input[dynamic_field_a_name])
					byte_ptr, buff = dynamic_field_b_ser(buff, byte_ptr, input[dynamic_field_b_name])
					byte_ptr, buff = dynamic_field_c_ser(buff, byte_ptr, input[dynamic_field_c_name])
					return byte_ptr, buff
				end
				@native --dynamic_ncgen
				function dynamic_portion_decode(buff: buffer, byte_ptr: number, output: any): (number)
					byte_ptr, output[dynamic_field_a_name] = dynamic_field_a_des(buff, byte_ptr)
					byte_ptr, output[dynamic_field_b_name] = dynamic_field_b_des(buff, byte_ptr)
					byte_ptr, output[dynamic_field_c_name] = dynamic_field_c_des(buff, byte_ptr)
					return byte_ptr
				end
			elseif num_dynamic_keys == 4 then
				@native --dynamic_ncgen
				function dynamic_portion_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
					byte_ptr, buff = dynamic_field_a_ser(buff, byte_ptr, input[dynamic_field_a_name])
					byte_ptr, buff = dynamic_field_b_ser(buff, byte_ptr, input[dynamic_field_b_name])
					byte_ptr, buff = dynamic_field_c_ser(buff, byte_ptr, input[dynamic_field_c_name])
					byte_ptr, buff = dynamic_field_d_ser(buff, byte_ptr, input[dynamic_field_d_name])
					return byte_ptr, buff
				end
				@native --dynamic_ncgen
				function dynamic_portion_decode(buff: buffer, byte_ptr: number, output: any): (number)
					byte_ptr, output[dynamic_field_a_name] = dynamic_field_a_des(buff, byte_ptr)
					byte_ptr, output[dynamic_field_b_name] = dynamic_field_b_des(buff, byte_ptr)
					byte_ptr, output[dynamic_field_c_name] = dynamic_field_c_des(buff, byte_ptr)
					byte_ptr, output[dynamic_field_d_name] = dynamic_field_d_des(buff, byte_ptr)
					return byte_ptr
				end
			elseif num_dynamic_keys == 5 then
				@native --dynamic_ncgen
				function dynamic_portion_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
					byte_ptr, buff = dynamic_field_a_ser(buff, byte_ptr, input[dynamic_field_a_name])
					byte_ptr, buff = dynamic_field_b_ser(buff, byte_ptr, input[dynamic_field_b_name])
					byte_ptr, buff = dynamic_field_c_ser(buff, byte_ptr, input[dynamic_field_c_name])
					byte_ptr, buff = dynamic_field_d_ser(buff, byte_ptr, input[dynamic_field_d_name])
					byte_ptr, buff = dynamic_field_e_ser(buff, byte_ptr, input[dynamic_field_e_name])
					return byte_ptr, buff
				end
				@native --dynamic_ncgen
				function dynamic_portion_decode(buff: buffer, byte_ptr: number, output: any): (number)
					byte_ptr, output[dynamic_field_a_name] = dynamic_field_a_des(buff, byte_ptr)
					byte_ptr, output[dynamic_field_b_name] = dynamic_field_b_des(buff, byte_ptr)
					byte_ptr, output[dynamic_field_c_name] = dynamic_field_c_des(buff, byte_ptr)
					byte_ptr, output[dynamic_field_d_name] = dynamic_field_d_des(buff, byte_ptr)
					byte_ptr, output[dynamic_field_e_name] = dynamic_field_e_des(buff, byte_ptr)
					return byte_ptr
				end
			elseif num_dynamic_keys == 6 then
				@native --dynamic_ncgen
				function dynamic_portion_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
					byte_ptr, buff = dynamic_field_a_ser(buff, byte_ptr, input[dynamic_field_a_name])
					byte_ptr, buff = dynamic_field_b_ser(buff, byte_ptr, input[dynamic_field_b_name])
					byte_ptr, buff = dynamic_field_c_ser(buff, byte_ptr, input[dynamic_field_c_name])
					byte_ptr, buff = dynamic_field_d_ser(buff, byte_ptr, input[dynamic_field_d_name])
					byte_ptr, buff = dynamic_field_e_ser(buff, byte_ptr, input[dynamic_field_e_name])
					byte_ptr, buff = dynamic_field_f_ser(buff, byte_ptr, input[dynamic_field_f_name])
					return byte_ptr, buff
				end
				@native --dynamic_ncgen
				function dynamic_portion_decode(buff: buffer, byte_ptr: number, output: any): (number)
					byte_ptr, output[dynamic_field_a_name] = dynamic_field_a_des(buff, byte_ptr)
					byte_ptr, output[dynamic_field_b_name] = dynamic_field_b_des(buff, byte_ptr)
					byte_ptr, output[dynamic_field_c_name] = dynamic_field_c_des(buff, byte_ptr)
					byte_ptr, output[dynamic_field_d_name] = dynamic_field_d_des(buff, byte_ptr)
					byte_ptr, output[dynamic_field_e_name] = dynamic_field_e_des(buff, byte_ptr)
					byte_ptr, output[dynamic_field_f_name] = dynamic_field_f_des(buff, byte_ptr)
					return byte_ptr
				end
			elseif num_dynamic_keys == 7 then
				@native --dynamic_ncgen
				function dynamic_portion_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
					byte_ptr, buff = dynamic_field_a_ser(buff, byte_ptr, input[dynamic_field_a_name])
					byte_ptr, buff = dynamic_field_b_ser(buff, byte_ptr, input[dynamic_field_b_name])
					byte_ptr, buff = dynamic_field_c_ser(buff, byte_ptr, input[dynamic_field_c_name])
					byte_ptr, buff = dynamic_field_d_ser(buff, byte_ptr, input[dynamic_field_d_name])
					byte_ptr, buff = dynamic_field_e_ser(buff, byte_ptr, input[dynamic_field_e_name])
					byte_ptr, buff = dynamic_field_f_ser(buff, byte_ptr, input[dynamic_field_f_name])
					byte_ptr, buff = dynamic_field_g_ser(buff, byte_ptr, input[dynamic_field_g_name])
					return byte_ptr, buff
				end
				@native --dynamic_ncgen
				function dynamic_portion_decode(buff: buffer, byte_ptr: number, output: any): (number)
					byte_ptr, output[dynamic_field_a_name] = dynamic_field_a_des(buff, byte_ptr)
					byte_ptr, output[dynamic_field_b_name] = dynamic_field_b_des(buff, byte_ptr)
					byte_ptr, output[dynamic_field_c_name] = dynamic_field_c_des(buff, byte_ptr)
					byte_ptr, output[dynamic_field_d_name] = dynamic_field_d_des(buff, byte_ptr)
					byte_ptr, output[dynamic_field_e_name] = dynamic_field_e_des(buff, byte_ptr)
					byte_ptr, output[dynamic_field_f_name] = dynamic_field_f_des(buff, byte_ptr)
					byte_ptr, output[dynamic_field_g_name] = dynamic_field_g_des(buff, byte_ptr)
					return byte_ptr
				end
			elseif num_dynamic_keys == 8 then
				@native --dynamic_ncgen
				function dynamic_portion_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
					byte_ptr, buff = dynamic_field_a_ser(buff, byte_ptr, input[dynamic_field_a_name])
					byte_ptr, buff = dynamic_field_b_ser(buff, byte_ptr, input[dynamic_field_b_name])
					byte_ptr, buff = dynamic_field_c_ser(buff, byte_ptr, input[dynamic_field_c_name])
					byte_ptr, buff = dynamic_field_d_ser(buff, byte_ptr, input[dynamic_field_d_name])
					byte_ptr, buff = dynamic_field_e_ser(buff, byte_ptr, input[dynamic_field_e_name])
					byte_ptr, buff = dynamic_field_f_ser(buff, byte_ptr, input[dynamic_field_f_name])
					byte_ptr, buff = dynamic_field_g_ser(buff, byte_ptr, input[dynamic_field_g_name])
					byte_ptr, buff = dynamic_field_h_ser(buff, byte_ptr, input[dynamic_field_h_name])
					return byte_ptr, buff
				end
				@native --dynamic_ncgen
				function dynamic_portion_decode(buff: buffer, byte_ptr: number, output: any): (number)
					byte_ptr, output[dynamic_field_a_name] = dynamic_field_a_des(buff, byte_ptr)
					byte_ptr, output[dynamic_field_b_name] = dynamic_field_b_des(buff, byte_ptr)
					byte_ptr, output[dynamic_field_c_name] = dynamic_field_c_des(buff, byte_ptr)
					byte_ptr, output[dynamic_field_d_name] = dynamic_field_d_des(buff, byte_ptr)
					byte_ptr, output[dynamic_field_e_name] = dynamic_field_e_des(buff, byte_ptr)
					byte_ptr, output[dynamic_field_f_name] = dynamic_field_f_des(buff, byte_ptr)
					byte_ptr, output[dynamic_field_g_name] = dynamic_field_g_des(buff, byte_ptr)
					byte_ptr, output[dynamic_field_h_name] = dynamic_field_h_des(buff, byte_ptr)
					return byte_ptr
				end
			else
				@native --dynamic_ncgen
				function dynamic_portion_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
					for index = 1, num_dynamic_keys do
						local field_name = dynamic_keys[index]

						local field_ser = dynamic_fields_ser[index]

						byte_ptr, buff = field_ser(buff, byte_ptr, input[field_name])
					end
					return byte_ptr, buff
				end
				@native --dynamic_ncgen
				function dynamic_portion_decode(buff: buffer, byte_ptr: number, output: any): (number)
					for index = 1, num_dynamic_keys do
						local field_name = dynamic_keys[index]

						local field_des = dynamic_fields_des[index]

						byte_ptr, output[field_name] = field_des(buff, byte_ptr)
					end
					return byte_ptr
				end
			end

			@native --dynamic_ncgen
			function struct_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
				local len = buffer.len(buff)

				local target_ptr = byte_ptr + struct_static_size
				--stylua: ignore
				do -- alloc
					if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
				end

				static_portion_ser_static(buff, byte_ptr, input)
				byte_ptr = target_ptr

				byte_ptr, buff = dynamic_portion_ser(buff, byte_ptr, input)

				return byte_ptr, buff
			end

			@native --dynamic_ncgen
			function struct_des(buff: buffer, byte_ptr: number): (number, any)
				local output = table.clone(clone_template)

				for index = 1, num_static_keys do
					local field_name = static_keys[index]

					local field_des = static_fields_des[index]

					byte_ptr, output[field_name] = field_des(buff, byte_ptr)
				end
				for index = 1, num_dynamic_keys do
					local field_name = dynamic_keys[index]

					local field_des = dynamic_fields_des[index]

					byte_ptr, output[field_name] = field_des(buff, byte_ptr)
				end

				return byte_ptr, output
			end
		else
			local field_a_name = dynamic_keys[1]
			local field_a_ser = dynamic_fields_ser[1]
			local field_a_des = dynamic_fields_des[1]
			local field_b_name = dynamic_keys[2]
			local field_b_ser = dynamic_fields_ser[2]
			local field_b_des = dynamic_fields_des[2]
			local field_c_name = dynamic_keys[3]
			local field_c_ser = dynamic_fields_ser[3]
			local field_c_des = dynamic_fields_des[3]
			local field_d_name = dynamic_keys[4]
			local field_d_ser = dynamic_fields_ser[4]
			local field_d_des = dynamic_fields_des[4]
			local field_e_name = dynamic_keys[5]
			local field_e_ser = dynamic_fields_ser[5]
			local field_e_des = dynamic_fields_des[5]
			local field_f_name = dynamic_keys[6]
			local field_f_ser = dynamic_fields_ser[6]
			local field_f_des = dynamic_fields_des[6]
			local field_g_name = dynamic_keys[7]
			local field_g_ser = dynamic_fields_ser[7]
			local field_g_des = dynamic_fields_des[7]
			local field_h_name = dynamic_keys[8]
			local field_h_ser = dynamic_fields_ser[8]
			local field_h_des = dynamic_fields_des[8]

			if num_dynamic_keys == 1 then
				@native --dynamic_ncgen
				function struct_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
					byte_ptr, buff = field_a_ser(buff, byte_ptr, input[field_a_name])
					return byte_ptr, buff
				end
				@native --dynamic_ncgen
				function struct_des(buff: buffer, byte_ptr: number): (number, any)
					local output = table.clone(clone_template)
					byte_ptr, output[field_a_name] = field_a_des(buff, byte_ptr)
					return byte_ptr, output
				end
			elseif num_dynamic_keys == 2 then
				@native --dynamic_ncgen
				function struct_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
					byte_ptr, buff = field_a_ser(buff, byte_ptr, input[field_a_name])
					byte_ptr, buff = field_b_ser(buff, byte_ptr, input[field_b_name])
					return byte_ptr, buff
				end
				@native --dynamic_ncgen
				function struct_des(buff: buffer, byte_ptr: number): (number, any)
					local output = table.clone(clone_template)
					byte_ptr, output[field_a_name] = field_a_des(buff, byte_ptr)
					byte_ptr, output[field_b_name] = field_b_des(buff, byte_ptr)
					return byte_ptr, output
				end
			elseif num_dynamic_keys == 3 then
				@native --dynamic_ncgen
				function struct_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
					byte_ptr, buff = field_a_ser(buff, byte_ptr, input[field_a_name])
					byte_ptr, buff = field_b_ser(buff, byte_ptr, input[field_b_name])
					byte_ptr, buff = field_c_ser(buff, byte_ptr, input[field_c_name])
					return byte_ptr, buff
				end
				@native --dynamic_ncgen
				function struct_des(buff: buffer, byte_ptr: number): (number, any)
					local output = table.clone(clone_template)
					byte_ptr, output[field_a_name] = field_a_des(buff, byte_ptr)
					byte_ptr, output[field_b_name] = field_b_des(buff, byte_ptr)
					byte_ptr, output[field_c_name] = field_c_des(buff, byte_ptr)
					return byte_ptr, output
				end
			elseif num_dynamic_keys == 4 then
				@native --dynamic_ncgen
				function struct_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
					byte_ptr, buff = field_a_ser(buff, byte_ptr, input[field_a_name])
					byte_ptr, buff = field_b_ser(buff, byte_ptr, input[field_b_name])
					byte_ptr, buff = field_c_ser(buff, byte_ptr, input[field_c_name])
					byte_ptr, buff = field_d_ser(buff, byte_ptr, input[field_d_name])
					return byte_ptr, buff
				end
				@native --dynamic_ncgen
				function struct_des(buff: buffer, byte_ptr: number): (number, any)
					local output = table.clone(clone_template)
					byte_ptr, output[field_a_name] = field_a_des(buff, byte_ptr)
					byte_ptr, output[field_b_name] = field_b_des(buff, byte_ptr)
					byte_ptr, output[field_c_name] = field_c_des(buff, byte_ptr)
					byte_ptr, output[field_d_name] = field_d_des(buff, byte_ptr)
					return byte_ptr, output
				end
			elseif num_dynamic_keys == 5 then
				@native --dynamic_ncgen
				function struct_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
					byte_ptr, buff = field_a_ser(buff, byte_ptr, input[field_a_name])
					byte_ptr, buff = field_b_ser(buff, byte_ptr, input[field_b_name])
					byte_ptr, buff = field_c_ser(buff, byte_ptr, input[field_c_name])
					byte_ptr, buff = field_d_ser(buff, byte_ptr, input[field_d_name])
					byte_ptr, buff = field_e_ser(buff, byte_ptr, input[field_e_name])
					return byte_ptr, buff
				end
				@native --dynamic_ncgen
				function struct_des(buff: buffer, byte_ptr: number): (number, any)
					local output = table.clone(clone_template)
					byte_ptr, output[field_a_name] = field_a_des(buff, byte_ptr)
					byte_ptr, output[field_b_name] = field_b_des(buff, byte_ptr)
					byte_ptr, output[field_c_name] = field_c_des(buff, byte_ptr)
					byte_ptr, output[field_d_name] = field_d_des(buff, byte_ptr)
					byte_ptr, output[field_e_name] = field_e_des(buff, byte_ptr)
					return byte_ptr, output
				end
			elseif num_dynamic_keys == 6 then
				@native --dynamic_ncgen
				function struct_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
					byte_ptr, buff = field_a_ser(buff, byte_ptr, input[field_a_name])
					byte_ptr, buff = field_b_ser(buff, byte_ptr, input[field_b_name])
					byte_ptr, buff = field_c_ser(buff, byte_ptr, input[field_c_name])
					byte_ptr, buff = field_d_ser(buff, byte_ptr, input[field_d_name])
					byte_ptr, buff = field_e_ser(buff, byte_ptr, input[field_e_name])
					byte_ptr, buff = field_f_ser(buff, byte_ptr, input[field_f_name])
					return byte_ptr, buff
				end
				@native --dynamic_ncgen
				function struct_des(buff: buffer, byte_ptr: number): (number, any)
					local output = table.clone(clone_template)
					byte_ptr, output[field_a_name] = field_a_des(buff, byte_ptr)
					byte_ptr, output[field_b_name] = field_b_des(buff, byte_ptr)
					byte_ptr, output[field_c_name] = field_c_des(buff, byte_ptr)
					byte_ptr, output[field_d_name] = field_d_des(buff, byte_ptr)
					byte_ptr, output[field_e_name] = field_e_des(buff, byte_ptr)
					byte_ptr, output[field_f_name] = field_f_des(buff, byte_ptr)
					return byte_ptr, output
				end
			elseif num_dynamic_keys == 7 then
				@native --dynamic_ncgen
				function struct_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
					byte_ptr, buff = field_a_ser(buff, byte_ptr, input[field_a_name])
					byte_ptr, buff = field_b_ser(buff, byte_ptr, input[field_b_name])
					byte_ptr, buff = field_c_ser(buff, byte_ptr, input[field_c_name])
					byte_ptr, buff = field_d_ser(buff, byte_ptr, input[field_d_name])
					byte_ptr, buff = field_e_ser(buff, byte_ptr, input[field_e_name])
					byte_ptr, buff = field_f_ser(buff, byte_ptr, input[field_f_name])
					byte_ptr, buff = field_g_ser(buff, byte_ptr, input[field_g_name])
					return byte_ptr, buff
				end
				@native --dynamic_ncgen
				function struct_des(buff: buffer, byte_ptr: number): (number, any)
					local output = table.clone(clone_template)
					byte_ptr, output[field_a_name] = field_a_des(buff, byte_ptr)
					byte_ptr, output[field_b_name] = field_b_des(buff, byte_ptr)
					byte_ptr, output[field_c_name] = field_c_des(buff, byte_ptr)
					byte_ptr, output[field_d_name] = field_d_des(buff, byte_ptr)
					byte_ptr, output[field_e_name] = field_e_des(buff, byte_ptr)
					byte_ptr, output[field_f_name] = field_f_des(buff, byte_ptr)
					byte_ptr, output[field_g_name] = field_g_des(buff, byte_ptr)
					return byte_ptr, output
				end
			elseif num_dynamic_keys == 8 then
				@native --dynamic_ncgen
				function struct_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
					byte_ptr, buff = field_a_ser(buff, byte_ptr, input[field_a_name])
					byte_ptr, buff = field_b_ser(buff, byte_ptr, input[field_b_name])
					byte_ptr, buff = field_c_ser(buff, byte_ptr, input[field_c_name])
					byte_ptr, buff = field_d_ser(buff, byte_ptr, input[field_d_name])
					byte_ptr, buff = field_e_ser(buff, byte_ptr, input[field_e_name])
					byte_ptr, buff = field_f_ser(buff, byte_ptr, input[field_f_name])
					byte_ptr, buff = field_g_ser(buff, byte_ptr, input[field_g_name])
					byte_ptr, buff = field_h_ser(buff, byte_ptr, input[field_h_name])
					return byte_ptr, buff
				end
				@native --dynamic_ncgen
				function struct_des(buff: buffer, byte_ptr: number): (number, any)
					local output = table.clone(clone_template)
					byte_ptr, output[field_a_name] = field_a_des(buff, byte_ptr)
					byte_ptr, output[field_b_name] = field_b_des(buff, byte_ptr)
					byte_ptr, output[field_c_name] = field_c_des(buff, byte_ptr)
					byte_ptr, output[field_d_name] = field_d_des(buff, byte_ptr)
					byte_ptr, output[field_e_name] = field_e_des(buff, byte_ptr)
					byte_ptr, output[field_f_name] = field_f_des(buff, byte_ptr)
					byte_ptr, output[field_g_name] = field_g_des(buff, byte_ptr)
					byte_ptr, output[field_h_name] = field_h_des(buff, byte_ptr)
					return byte_ptr, output
				end
			else
				@native --dynamic_ncgen
				function struct_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
					for index = 1, num_dynamic_keys do
						local field_name = dynamic_keys[index]

						local field_value = input[field_name]

						byte_ptr, buff = dynamic_fields_ser[index](buff, byte_ptr, field_value)
					end

					return byte_ptr, buff
				end

				@native --dynamic_ncgen
				function struct_des(buff: buffer, byte_ptr: number): (number, any)
					local output = table.clone(clone_template)

					for index = 1, num_dynamic_keys do
						local field_name = dynamic_keys[index]

						local field_des = dynamic_fields_des[index]

						byte_ptr, output[field_name] = field_des(buff, byte_ptr)
					end

					return byte_ptr, output
				end
			end
		end

		metadata.ser_no_realloc[struct_datatype] = struct_ser_no_realloc
		metadata.ser_static[struct_datatype] = struct_ser_static
		metadata.ser[struct_datatype] = struct_ser
		metadata.des[struct_datatype] = struct_des

		return struct_datatype
	end

datatypes.struct = struct :: <Template>(Template) -> (Datatype<Template>) end

do
	local cache = {} :: { [Datatype]: Datatype<vector> }
	local function vect3(coord_datatype: Datatype<number>?): Datatype<vector>
		local coord_datatype = (coord_datatype or datatypes.f32) :: Datatype
	
		local cached = cache[coord_datatype]
		if cached ~= nil then return cached end

		if not check_datatype_exists(coord_datatype) then
			error(debug.traceback(`Invalid vect3: coord must be a valid datatype. Got id: "{coord_datatype}"`))
		elseif not metadata.is_number[coord_datatype] then
			error(debug.traceback(`Invalid vect3: coord must be a number datatype. Got id: "{coord_datatype}"`))
		end
		
		local coord_static_size = metadata.static_size[coord_datatype]
		local coord_des = metadata.des[coord_datatype]
		local vect3_static_size = coord_static_size and coord_static_size * 3

		local vect3_datatype = new_datatype(vect3_static_size)
		cache[coord_datatype] = vect3_datatype :: Datatype<vector>
		
		local vect3_ser_no_realloc, vect3_ser_static, vect3_ser, vect3_des

		if coord_static_size then
			local coord_ser_static = metadata.ser_static[coord_datatype]

			@native --dynamic_ncgen
			function vect3_ser_no_realloc(buff: buffer, byte_ptr: number, data: any): (number)
				coord_ser_static(buff, byte_ptr, data.x)
				byte_ptr += coord_static_size

				coord_ser_static(buff, byte_ptr, data.y)
				byte_ptr += coord_static_size

				coord_ser_static(buff, byte_ptr, data.z)
				byte_ptr += coord_static_size

				return byte_ptr
			end

			@native --dynamic_ncgen
			function vect3_ser_static(buff: buffer, byte_ptr: number, data: any): ()
				coord_ser_static(buff, byte_ptr, data.x)
				byte_ptr += coord_static_size

				coord_ser_static(buff, byte_ptr, data.y)
				byte_ptr += coord_static_size

				coord_ser_static(buff, byte_ptr, data.z)
			end

			@native --dynamic_ncgen
			function vect3_ser(buff: buffer, byte_ptr: number, data: any): (number, buffer)
				local len = buffer.len(buff)

				local target_ptr = byte_ptr + vect3_static_size
				--stylua: ignore
				do -- alloc
					if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
				end

				coord_ser_static(buff, byte_ptr, data.x)
				byte_ptr += coord_static_size

				coord_ser_static(buff, byte_ptr, data.y)
				byte_ptr += coord_static_size

				coord_ser_static(buff, byte_ptr, data.z)

				return target_ptr, buff
			end
		elseif not coord_static_size then
			local coord_ser = metadata.ser[coord_datatype]

			@native --dynamic_ncgen
			function vect3_ser(buff: buffer, byte_ptr: number, data: any): (number, buffer)
				byte_ptr, buff = coord_ser(buff, byte_ptr, data.x)
				byte_ptr, buff = coord_ser(buff, byte_ptr, data.y)
				byte_ptr, buff = coord_ser(buff, byte_ptr, data.z)

				return byte_ptr, buff
			end
		else
			stfu_check()
			error(debug.traceback("unreachable"))
		end

		@native --dynamic_ncgen
		function vect3_des(buff: buffer, byte_ptr: number): (number, any)
			--[[TL;DR this is the fastest way i could find to do this
			benched on a whim (o2, x10k iter):
			- upval x,y,z: 180µs
			- local byte_ptr, coord = des: 140µs
			- local x,y,z: 130µs
			- [NATIVE] upval x,y,z: 161µs
			- [NATIVE] local coord, byte_ptr = des: 43µs
			- [NATIVE] local x,y,z: 41µs
			]]
			local x, y, z

			byte_ptr, x = coord_des(buff, byte_ptr)
			byte_ptr, y = coord_des(buff, byte_ptr)
			byte_ptr, z = coord_des(buff, byte_ptr)

			return byte_ptr, vector.create(x, y, z)
		end

		metadata.ser_no_realloc[vect3_datatype] = vect3_ser_no_realloc
		metadata.ser_static[vect3_datatype] = vect3_ser_static
		metadata.ser[vect3_datatype] = vect3_ser
		metadata.des[vect3_datatype] = vect3_des

		return vect3_datatype
	end

datatypes.vect3 = vect3 end

do
	local cache = {} :: { [Datatype]: Datatype<vector> }
	local function vect2(coord_datatype: Datatype<number>?): Datatype<vector>
		local coord_datatype = (coord_datatype or datatypes.f32) :: Datatype
	
		local cached = cache[coord_datatype]
		if cached ~= nil then return cached end

		if not check_datatype_exists(coord_datatype) then
			error(debug.traceback(`Invalid vect2: coord must be a valid datatype. Got id: "{coord_datatype}"`))
		elseif not metadata.is_number[coord_datatype] then
			error(debug.traceback(`Invalid vect2: coord must be a number datatype. Got id: "{coord_datatype}"`))
		end

		local coord_static_size = metadata.static_size[coord_datatype]
		local coord_des = metadata.des[coord_datatype]

		local vect2_static_size = coord_static_size and coord_static_size * 2
		
		local vect2_datatype = new_datatype(vect2_static_size)
		cache[coord_datatype] = vect2_datatype :: Datatype<vector>

		local vect2_ser_no_realloc, vect2_ser_static, vect2_ser, vect2_des

		if coord_static_size then
			local coord_ser_static = metadata.ser_static[coord_datatype]

			@native --dynamic_ncgen
			function vect2_ser_no_realloc(buff: buffer, byte_ptr: number, data: any): (number)
				coord_ser_static(buff, byte_ptr, data.x)
				byte_ptr += coord_static_size

				coord_ser_static(buff, byte_ptr, data.y)
				byte_ptr += coord_static_size

				return byte_ptr
			end

			@native --dynamic_ncgen
			function vect2_ser_static(buff: buffer, byte_ptr: number, data: any): ()
				coord_ser_static(buff, byte_ptr, data.x)
				byte_ptr += coord_static_size

				coord_ser_static(buff, byte_ptr, data.y)
			end

			@native --dynamic_ncgen
			function vect2_ser(buff: buffer, byte_ptr: number, data: any): (number, buffer)
				local len = buffer.len(buff)

				local target_ptr = byte_ptr + vect2_static_size
				--stylua: ignore
				do -- alloc
					if target_ptr > len then local old_buff = buff; len *= 2; while target_ptr > len do len *= 2 end; buff = buffer.create(len); buffer.copy(buff, 0, old_buff, 0, byte_ptr); end
				end

				coord_ser_static(buff, byte_ptr, data.x)
				byte_ptr += coord_static_size

				coord_ser_static(buff, byte_ptr, data.y)

				return target_ptr, buff
			end
		elseif not coord_static_size then
			local coord_ser = metadata.ser[coord_datatype]

			@native --dynamic_ncgen
			function vect2_ser(buff: buffer, byte_ptr: number, data: any): (number, buffer)
				byte_ptr, buff = coord_ser(buff, byte_ptr, data.x)
				byte_ptr, buff = coord_ser(buff, byte_ptr, data.y)

				return byte_ptr, buff
			end
		else
			stfu_check()
			error(debug.traceback("unreachable"))
		end

		@native --dynamic_ncgen
		function vect2_des(buff: buffer, byte_ptr: number): (number, any)
			local x, y

			byte_ptr, x = coord_des(buff, byte_ptr)
			byte_ptr, y = coord_des(buff, byte_ptr)

			return byte_ptr, vector.create(x, y)
		end

		metadata.ser_no_realloc[vect2_datatype] = vect2_ser_no_realloc
		metadata.ser_static[vect2_datatype] = vect2_ser_static
		metadata.ser[vect2_datatype] = vect2_ser
		metadata.des[vect2_datatype] = vect2_des

		return vect2_datatype
	end

datatypes.vect2 = vect2 end

do
	local function computed<T>(call: () -> (Datatype<T>)): Datatype<T>
		local ser_functions = metadata.ser
		local des_functions = metadata.des

		local computed_datatype = new_datatype()

		local function computed_ser(...: any): (number, buffer)
			return ser_functions[call()](... :: any)
		end
		local function computed_des(...: any): (number, any)
			return des_functions[call()](... :: any)
		end

		ser_functions[computed_datatype] = computed_ser
		des_functions[computed_datatype] = computed_des

		return computed_datatype
	end

datatypes.computed = computed end

local holy = {
	_datatype_metadata = metadata,
	_stfu_check = stfu_check,
	_is_stfu = is_stfu,

	fetch = {
		ser_no_realloc = fetch_ser_no_realloc,
		ser_static = fetch_ser_static,
		ser = fetch_ser,
		des = fetch_des,
	},

	export = export_datatype,
	new_datatype = new_datatype,
	check_datatype_exists = check_datatype_exists,
	copy_datatype = copy_datatype,

	const_lookups = CONST_LOOKUPS,

	datatypes = datatypes,

	uint_size = uint_size_bytes,
	vlq_size = vlq_size_bytes,

	stfu = stfu,
}

return holy
