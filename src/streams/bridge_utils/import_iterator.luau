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
TODO: cleanup this file
TODO: stop doing thread manipulation in an ITERATOR
]]
--!optimize 2
do
end
local bitpack = require("../../bitpack")
local holy = require("../../holy")
local incoming_stream_state = require("../../streams/incoming_state")
local internal_datatypes = require("../../internal_datatypes")
local message_types = require("../../messages/types")
local report = require("../../report")

type MessageId = message_types.MessageId
type MessageCallCount = number
type MessageData = any

local ty = holy.datatypes
local metadata = holy._datatype_metadata
local low_message_datatype = internal_datatypes.low_message
local high_message_datatype = internal_datatypes.high_message
local low_message_id_des = metadata.des[low_message_datatype]
local high_message_id_des = metadata.des[high_message_datatype]
local vlq2_datatype = ty.vlq(2)
local bitpack_boundary_array_datatype = ty.arr(ty.u8, vlq2_datatype)
local vlq2_des = metadata.des[vlq2_datatype]
local bitpack_boundary_array_des = metadata.des[bitpack_boundary_array_datatype]
local bitpack_import_byte = bitpack.import_byte
local bitpack_import = bitpack.import
local des = metadata.des

--[=[
evil workaround to avoid casting bool, remove when luau fixes operator typing stuff
]=]
local function invert(bool: boolean): boolean
	return not bool
end

--[=[
Use coroutine.wrap() to iterate
]=]
local function new_iterator(
	recv_buff: buffer,
	recv_unknown: { unknown }?
): (MessageId, MessageCallCount, { MessageData })
	coroutine.yield()
	-- setting current unknown table isn't conditional because it could lead to information leak
	incoming_stream_state._current_unknowns = recv_unknown
	if recv_unknown ~= nil then incoming_stream_state._current_unknown_cursor = 1 end

	local recv_ptr = 0

	local has_bitpack_boundary_array, has_low_messages, has_high_messages
	recv_ptr, has_bitpack_boundary_array, has_low_messages, has_high_messages =
		bitpack_import_byte(recv_buff, recv_ptr)

	local bitpack_boundary_arr = {} :: { number }
	local bitpack_boundary_index = 1
	if has_bitpack_boundary_array then
		recv_ptr, bitpack_boundary_arr = bitpack_boundary_array_des(recv_buff, recv_ptr)
		bitpack_boundary_index = 1
	end
	local deserializing_bitpack: boolean = false

	--[[
	D.R.Y. hates me for showing you this one simple trick
	(Ctrl + C, Ctrl + V)
	]]
	if has_low_messages then
		-- print(`before deserializing low msg map len: {recv_ptr}`)
		local messages_map_length
		recv_ptr, messages_map_length = vlq2_des(recv_buff, recv_ptr)

		for i = 1, messages_map_length do
			local boundary_length = bitpack_boundary_arr[bitpack_boundary_index]
			if boundary_length then
				if boundary_length > 0 then
					boundary_length -= 1
					bitpack_boundary_arr[bitpack_boundary_index] = boundary_length
				else
					bitpack_boundary_index += 1
					deserializing_bitpack = invert(deserializing_bitpack)
				end
			end

			-- print(`before deserializing msg id: {recv_ptr}`)
			local message_id: MessageId
			recv_ptr, message_id = low_message_id_des(recv_buff, recv_ptr)

			-- print(`before deserializing send count: {recv_ptr}`)
			local message_send_count: number
			recv_ptr, message_send_count = vlq2_des(recv_buff, recv_ptr)

			local imported_bitpacker
			if deserializing_bitpack then
				-- print(`before deserializing bitpack: {recv_ptr}`)
				recv_ptr, imported_bitpacker = bitpack_import(recv_buff, recv_ptr)
			end
			-- can't allow data leaks on incoming stream state
			incoming_stream_state._current_bitunpacker = imported_bitpacker

			local message_deserializer = des[message_id]
			local message_data_table = table.create(message_send_count)

			-- print(`before deserializing messages: {recv_ptr}`)
			local message_data
			for message_data_index = 1, message_send_count do
				recv_ptr, message_data = message_deserializer(recv_buff, recv_ptr)
				message_data_table[message_data_index] = message_data
			end
			-- print(`after deserializing messages: {recv_ptr}`)

			coroutine.yield(message_id, message_send_count, message_data_table)
		end
	end
	if has_high_messages then
		local messages_map_length
		recv_ptr, messages_map_length = vlq2_des(recv_buff, recv_ptr)

		for i = 1, messages_map_length do
			local boundary_length = bitpack_boundary_arr[bitpack_boundary_index]
			if boundary_length then
				if boundary_length > 0 then
					boundary_length -= 1
					bitpack_boundary_arr[bitpack_boundary_index] = boundary_length
				else
					bitpack_boundary_index += 1
					deserializing_bitpack = invert(deserializing_bitpack)
				end
			end

			-- print(`before deserializing msg id: {recv_ptr}`)
			local message_id: MessageId
			recv_ptr, message_id = high_message_id_des(recv_buff, recv_ptr)

			-- print(`before deserializing send count: {recv_ptr}`)
			local message_send_count: number
			recv_ptr, message_send_count = vlq2_des(recv_buff, recv_ptr)

			local imported_bitpacker
			if deserializing_bitpack then
				-- print(`before deserializing bitpack: {recv_ptr}`)
				recv_ptr, imported_bitpacker = bitpack_import(recv_buff, recv_ptr)
			end
			-- can't allow data leaks on incoming stream state
			incoming_stream_state._current_bitunpacker = imported_bitpacker

			local message_deserializer = des[message_id]
			local message_data_table = table.create(message_send_count)

			-- print(`before deserializing messages: {recv_ptr}`)
			local message_data
			for message_data_index = 1, message_send_count do
				recv_ptr, message_data = message_deserializer(recv_buff, recv_ptr)
				message_data_table[message_data_index] = message_data
			end
			-- print(`after deserializing messages: {recv_ptr}`)

			coroutine.yield(message_id, message_send_count, message_data_table)
		end
	end
	coroutine.yield()
	error(report.bug(report.problem("resumed message data iterator after iteration complete")))
end

--[=[
Creates an iterator for (MessageId, MessageCallCount, { MessageData })
]=]
local function serve_iterator(
	recv_buff: buffer,
	recv_unknown: { unknown }?
): () -> (MessageId, MessageCallCount, { MessageData })
	local wrapped_iterator = coroutine.wrap(new_iterator)
	wrapped_iterator(recv_buff, recv_unknown)
	-- Luau
	return wrapped_iterator :: any
end

return serve_iterator
