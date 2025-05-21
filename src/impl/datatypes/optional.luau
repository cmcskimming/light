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
local U8_BYTES = 1

local _datatype_cached = require("./cached")
local bitpack = require("../../bitpack")
local datatypes = require("../../include/datatypes/main.h")
local holy = require("../../holy")
local incoming_stream_state = require("../../streams/incoming_state")
local outgoing_stream_state = require("../../streams/outgoing_state")
local report = require("../../report")

type BitUnpacker = bitpack.UnpackerIdentity
type HolyDatatype<T = any> = holy.Datatype<T>
type Ser<T = any> = holy.Ser<T>
type Des<T = any> = holy.Des<T>

local is_stfu = holy._is_stfu
local metadata = holy._datatype_metadata
local bitpack_push_true = bitpack.push_true
local bitpack_push_false = bitpack.push_false
local bitpack_read = bitpack.read

type function negate(T: type): type
	return types.negationof(T)
end

local cache = {} :: { [HolyDatatype]: HolyDatatype<negate<nil>?> }
function datatypes.optional<Inner>(inner_datatype: HolyDatatype<Inner>): HolyDatatype<Inner?>
	local inner_cached = datatypes.cached(inner_datatype)
	do
		local cached = cache[inner_cached]
		if cached ~= nil then return cached end
	end

	if metadata.is_nilable[inner_cached] and (is_stfu() == false) then
		warn(
			report.problem(
				`Optional<{inner_datatype}> where <{inner_datatype}> is a nilable datatype is likely unintentional.\n`
					.. [[
					If you intended to make an optional of an already nilable Datatype, you can silence this warning:
					```luau
					stfu(true)
					local abc = optional(optional(T))
					stfu(false)
					```
					]]
			)
		)
	end

	local inner_ser = metadata.ser[inner_cached]
	local inner_des = metadata.des[inner_cached]

	local optional_datatype = holy.new_datatype()
	cache[inner_cached] = optional_datatype

	@native --dynamic_ncgen
	local function optional_ser_io(buff: buffer, byte_ptr: number, input: any): (number, buffer)
		--stylua: ignore
		do
			local len = buffer.len(buff)
			local target_ptr = byte_ptr + U8_BYTES
			if target_ptr > len then local old_buf = buff;len *= 2;while target_ptr > len do len *= 2;end;buff = buffer.create(len);buffer.copy(buff, 0, old_buf, 0, byte_ptr); end
		end
		if input == nil then
			buffer.writeu8(buff, byte_ptr, 0)
			byte_ptr += U8_BYTES
		else
			buffer.writeu8(buff, byte_ptr, 1)
			byte_ptr += U8_BYTES

			byte_ptr, buff = inner_ser(buff, byte_ptr, input)
		end

		return byte_ptr, buff
	end

	@native --dynamic_ncgen
	local function optional_des_io(buff: buffer, byte_ptr: number): (number, any?)
		local encoded_is_nil = buffer.readu8(buff, byte_ptr)
		byte_ptr += U8_BYTES

		local decoded_is_nil = encoded_is_nil ~= 1

		if decoded_is_nil then return byte_ptr, nil end

		local decoded
		byte_ptr, decoded = inner_des(buff, byte_ptr)

		return byte_ptr, decoded
	end

	@native --dynamic_ncgen
	local function optional_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
		if outgoing_stream_state._inside_io then return optional_ser_io(buff, byte_ptr, input) end

		local current_bitpack = outgoing_stream_state._current_bitpack :: bitpack.Identity

		if input == nil then
			bitpack_push_false(current_bitpack)
		else
			bitpack_push_true(current_bitpack)

			byte_ptr, buff = inner_ser(buff, byte_ptr, input)
		end

		return byte_ptr, buff
	end

	@native --dynamic_ncgen
	local function optional_des(buff: buffer, byte_ptr: number): (number, any)
		if incoming_stream_state._inside_io then return optional_des_io(buff, byte_ptr) end

		local current_unpacker = incoming_stream_state._current_bitunpacker :: BitUnpacker

		local bool = bitpack_read(current_unpacker)

		if bool then return inner_des(buff, byte_ptr) end

		return byte_ptr, nil
	end

	metadata.ser[optional_datatype] = optional_ser
	metadata.des[optional_datatype] = optional_des

	return optional_datatype
end

return nil
