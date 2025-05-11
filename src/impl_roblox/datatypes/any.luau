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
do
end
--- newproxy() gets encoded as nil over the network, preventing gaps in the unknown index
--- <br>cursed as hell but if it works it works
local NULL = newproxy()
local U16_BYTES = 2

local datatypes = require("../../include/datatypes/main.h")
local holy = require("../../holy")
local incoming_stream_state = require("../../streams/incoming_state")
local outgoing_stream_state = require("../../streams/outgoing_state")
local stream_types = require("../../streams/types")

type HolyDatatype<T = any> = holy.Datatype<T>
type OutgoingStream = stream_types.OutgoingStream

local metadata = holy._datatype_metadata

local any_type = holy.new_datatype(U16_BYTES) :: HolyDatatype<any>

@native
local function any_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): number
	local current_outgoing_stream = outgoing_stream_state._current_outgoing :: OutgoingStream

	local unknown_table = current_outgoing_stream.batch_unknown
	local unknown_len = current_outgoing_stream.batch_unknown_len

	unknown_len += 1
	current_outgoing_stream.batch_unknown_len = unknown_len

	unknown_table[unknown_len] = if input == nil then NULL else input

	buffer.writeu16(buff, byte_ptr, unknown_len)
	byte_ptr += U16_BYTES

	return byte_ptr
end

@native
local function any_ser_static(buff: buffer, byte_ptr: number, input: any): ()
	local current_outgoing_stream = outgoing_stream_state._current_outgoing :: OutgoingStream

	local unknown_table = current_outgoing_stream.batch_unknown
	local unknown_len = current_outgoing_stream.batch_unknown_len

	unknown_len += 1
	current_outgoing_stream.batch_unknown_len = unknown_len

	unknown_table[unknown_len] = if input == nil then NULL else input

	buffer.writeu16(buff, byte_ptr, unknown_len)
end

@native
local function any_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
	local current_outgoing_stream = outgoing_stream_state._current_outgoing :: OutgoingStream

	local unknown_table = current_outgoing_stream.batch_unknown
	local unknown_len = current_outgoing_stream.batch_unknown_len

	unknown_len += 1
	current_outgoing_stream.batch_unknown_len = unknown_len

	unknown_table[unknown_len] = if input == nil then NULL else input

	local target_ptr = byte_ptr + U16_BYTES
	--stylua: ignore
	do
		local len = buffer.len(buff)
		if target_ptr > len then local old_buf = buff;len *= 2;while target_ptr > len do len *= 2;end;buff = buffer.create(len);buffer.copy(buff, 0, old_buf, 0, byte_ptr); end
	end
	buffer.writeu16(buff, byte_ptr, unknown_len)

	return target_ptr, buff
end

@native
local function any_des(buff: buffer, byte_ptr: number): (number, any)
	local unknown_table = incoming_stream_state._current_unknowns :: { unknown }

	local unknown_index = buffer.readu16(buff, byte_ptr)
	byte_ptr += U16_BYTES

	return byte_ptr, unknown_table[unknown_index]
end

metadata.ser_no_realloc[any_type] = any_ser_no_realloc
metadata.ser_static[any_type] = any_ser_static
metadata.ser[any_type] = any_ser
metadata.des[any_type] = any_des

datatypes.any = any_type :: any

return nil
