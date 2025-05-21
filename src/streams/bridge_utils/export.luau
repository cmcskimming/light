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
]]
do
end
local U8_BYTES = 1

local allocation = require("./export_allocation")
local bitpack = require("../../bitpack")
local holy = require("../../holy")
local internal_datatypes = require("../../internal_datatypes")
local message_types = require("../../messages/types")
local report = require("../../report")
local stream_types = require("../../streams/types")

type MessageId = message_types.MessageId
type OutgoingStream = stream_types.OutgoingStream

local allocate_bitpacks_and_get_opt_boundaries = allocation.allocate_bitpacks_and_get_opt_boundaries
local allocate_and_get_opt_message_id_maps = allocation.allocate_and_get_opt_message_id_maps
local allocate_bitpack_boundary_array = allocation.allocate_bitpack_boundary_array
local reset_allocated_size = allocation.reset_allocated_size
local allocate_opts = allocation.allocate_global_opts
local allocated_size = allocation.get_allocated_size
local ty = holy.datatypes
local metadata = holy._datatype_metadata
local low_message_datatype = internal_datatypes.low_message
local high_message_datatype = internal_datatypes.high_message
local low_messages_ser_no_realloc = metadata.ser_no_realloc[low_message_datatype]
local high_messages_ser_no_realloc = metadata.ser_no_realloc[high_message_datatype]
local vlq2_datatype = ty.vlq(2)
local bitpack_boundary_array_datatype = ty.arr(ty.u8, vlq2_datatype)
local vlq2_ser = metadata.ser[vlq2_datatype]
local bitpack_boundary_array_ser = metadata.ser[bitpack_boundary_array_datatype]
local export_bitpack = bitpack.export
local bitpack_contains_data = bitpack.contains_data
local stfu_check = holy._stfu_check

local send_buff: buffer
local send_ptr = -1

local function export_opts(
	first: boolean?,
	second: boolean?,
	third: boolean?,
	fourth: boolean?,
	fifth: boolean?,
	sixth: boolean?,
	seventh: boolean?,
	eighth: boolean?
): ()
	local output = 0
	if first then
		output += 0b1
	end
	if second then
		output += 0b10
	end
	if third then
		output += 0b100
	end
	if fourth then
		output += 0b1000
	end
	if fifth then
		output += 0b10000
	end
	if sixth then
		output += 0b100000
	end
	if seventh then
		output += 0b1000000
	end
	if eighth then
		output += 0b10000000
	end
	buffer.writeu8(send_buff, send_ptr, output)
	send_ptr += U8_BYTES
end

local function export_bitpack_boundary_array(bitpack_boundary_array: { number }): ()
	local new_send_ptr: number, new_send_buff: buffer =
		bitpack_boundary_array_ser(send_buff, send_ptr, bitpack_boundary_array)

	if new_send_buff ~= send_buff then
		stfu_check()
		error(
			report.bug(
				report.problem(
					`Internal Bitpack Boundaries serialized with reallocations.`
						.. `\nBefore serialization ptr: {send_ptr}`
						.. `\nAfter serialization ptr: {new_send_ptr}`
				)
			)
		)
	end

	send_ptr = new_send_ptr
end

local function export(stream: OutgoingStream): buffer?
	reset_allocated_size()

	-- global opts byte to save on idle frames
	allocate_opts()

	local batched_cursor_and_send_count = stream.batched_cursor_and_send_count

	local low_message_ids, high_message_ids =
		allocate_and_get_opt_message_id_maps(batched_cursor_and_send_count)

	if (low_message_ids == nil) and (high_message_ids == nil) then return nil end

	local message_bitpacks = stream.message_bitpacks

	local bitpack_boundary_array =
		allocate_bitpacks_and_get_opt_boundaries(message_bitpacks, low_message_ids, high_message_ids)

	local boundary_array_exists = bitpack_boundary_array ~= nil

	if boundary_array_exists then
		allocate_bitpack_boundary_array(bitpack_boundary_array :: { number }) --
	end

	local send_size = allocated_size()
	send_buff = buffer.create(send_size)
	send_ptr = 0

	local low_messages_exists = low_message_ids ~= nil
	local high_messages_exists = high_message_ids ~= nil

	export_opts(boundary_array_exists, low_messages_exists, high_messages_exists)

	if boundary_array_exists then
		export_bitpack_boundary_array(bitpack_boundary_array :: { number })
	end

	local message_buffs = stream.message_buffs

	local new_buff
	--[[
	if luau won't inline it for me i'll have to do it myself
	]]
	if low_messages_exists then
		local message_ids = low_message_ids :: { MessageId }
		local ids_len = #message_ids

		-- print(`before serializing low msg map len: {send_ptr}`)
		send_ptr, new_buff = vlq2_ser(send_buff, send_ptr, ids_len)
		if new_buff ~= send_buff then
			stfu_check()
			error(report.bug(report.problem(`Reallocated while exporting low messages length`)))
		end

		for ids_index = 1, ids_len do
			-- print(`before serializing msg id: {send_ptr}`)
			local id = message_ids[ids_index]
			send_ptr = low_messages_ser_no_realloc(send_buff, send_ptr, id)

			local message_buff = message_buffs[id]

			local cursor_and_send_count = batched_cursor_and_send_count[id]

			local cursor = cursor_and_send_count.x
			local send_count = cursor_and_send_count.y

			-- print(`before serializing send count: {send_ptr}`)
			send_ptr, new_buff = vlq2_ser(send_buff, send_ptr, send_count)

			local bitpack = message_bitpacks[id]

			if bitpack_contains_data(bitpack) then
				-- print(`before serializing bitpack: {send_ptr}`)
				send_ptr, new_buff = export_bitpack(send_buff, send_ptr, bitpack)
			end

			if new_buff ~= send_buff then
				stfu_check()
				error(report.bug(report.problem(`Reallocated while exporting message id {id}`)))
			end

			-- print(`before serializing message data: {send_ptr}`)
			buffer.copy(send_buff, send_ptr, message_buff, 0, cursor)
			send_ptr += cursor
			-- print(`after serializing message data: {send_ptr}`)
		end
	end
	if high_messages_exists then
		local message_ids = high_message_ids :: { MessageId }
		local ids_len = #message_ids

		send_ptr, new_buff = vlq2_ser(send_buff, send_ptr, ids_len)
		if new_buff ~= send_buff then
			stfu_check()
			error(report.bug(report.problem(`Reallocated while exporting high messages length`)))
		end

		for ids_index = 1, ids_len do
			local id = message_ids[ids_index]
			send_ptr = high_messages_ser_no_realloc(send_buff, send_ptr, id)

			local message_buff = message_buffs[id]

			local cursor_and_send_count = batched_cursor_and_send_count[id]

			local cursor = cursor_and_send_count.x
			local send_count = cursor_and_send_count.y

			send_ptr, new_buff = vlq2_ser(send_buff, send_ptr, send_count)

			local bitpack = message_bitpacks[id]

			if bitpack_contains_data(bitpack) then
				send_ptr, new_buff = export_bitpack(send_buff, send_ptr, bitpack)
			end

			if new_buff ~= send_buff then
				stfu_check()
				error(report.bug(report.problem(`Reallocated while exporting message id {id}`)))
			end

			buffer.copy(send_buff, send_ptr, message_buff, 0, cursor)
			send_ptr += cursor
		end
	end

	return send_buff
end

return export
