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

local bitpack = require("../../bitpack")
local datatypes = require("../../include/datatypes/main.h")
local holy = require("../../holy")
local incoming_stream_state = require("../../streams/incoming_state")
local outgoing_stream_state = require("../../streams/outgoing_state")

type Bitpacker = bitpack.Identity
type BitUnpacker = bitpack.UnpackerIdentity

local bitpack_push_true = bitpack.push_true
local bitpack_push_false = bitpack.push_false
local bitpack_read = bitpack.read
local metadata = holy._datatype_metadata

local bool_datatype = holy.new_datatype()

@native
local function bool_ser_io(buff: buffer, byte_ptr: number, input: any): (number, buffer)
	--stylua: ignore
	do
		local len = buffer.len(buff)
		local target_ptr = byte_ptr + U8_BYTES
		if target_ptr > len then local old_buf = buff;len *= 2;while target_ptr > len do len *= 2;end;buff = buffer.create(len);buffer.copy(buff, 0, old_buf, 0, byte_ptr); end
	end
	buffer.writeu8(buff, byte_ptr, input and 1 or 0)
	byte_ptr += U8_BYTES

	return byte_ptr, buff
end

@native
local function bool_des_io(buff: buffer, byte_ptr: number): (number, any?)
	local output = buffer.readu8(buff, byte_ptr) == 1
	byte_ptr += U8_BYTES

	return byte_ptr, output
end

@native --dynamic_ncgen
local function bool_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
	if outgoing_stream_state._inside_io then return bool_ser_io(buff, byte_ptr, input) end

	local current_bitpack = outgoing_stream_state._current_bitpack :: Bitpacker

	if input then
		bitpack_push_true(current_bitpack)
	else
		bitpack_push_false(current_bitpack)
	end

	return byte_ptr, buff
end

@native --dynamic_ncgen
local function bool_des(buff: buffer, byte_ptr: number): (number, any)
	if incoming_stream_state._inside_io then return bool_des_io(buff, byte_ptr) end

	local current_unpacker = incoming_stream_state._current_bitunpacker :: BitUnpacker

	local output = bitpack_read(current_unpacker)

	return byte_ptr, output
end

metadata.ser[bool_datatype] = bool_ser
metadata.des[bool_datatype] = bool_des

datatypes.bool = bool_datatype :: any

return nil
