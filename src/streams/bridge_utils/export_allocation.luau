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
local U16_BYTES = 2
local OPTS_BYTES = U8_BYTES

local bitpack = require("../../bitpack")
local holy = require("../../holy")
local message_id = require("../../messages/id")
local message_types = require("../../messages/types")

type Bitpacker = bitpack.Identity
type MessageId = message_types.MessageId

local vlq_size = holy.vlq_size
local bitpack_contains_data = bitpack.contains_data
local evaluate_packer = bitpack.evaluate_packer

local LOW_MESSAGES_END = message_id.LOW_MESSAGES_END

local allocated = 0

local function allocate_low_message(): ()
	allocated += U8_BYTES
end

local function allocate_high_message(): ()
	allocated += U16_BYTES
end

local function allocate_raw(len: number): ()
	allocated += len
end

local function allocate_vlq(uint: number): ()
	allocated += vlq_size(uint)
end

local function allocate_packer(packer: Bitpacker): ()
	allocated += evaluate_packer(packer)
end

local function allocate_global_opts(): ()
	allocated += OPTS_BYTES
end

@native
local function allocate_and_get_opt_message_id_maps(
	batched_cursor_and_send_count: { [MessageId]: vector }
): ({ MessageId }?, { MessageId }?)
	local stream_is_empty = next(batched_cursor_and_send_count) == nil
	if stream_is_empty then return nil, nil end

	local low_message_ids = {}
	local low_message_ids_length = 0

	local high_message_ids = {}
	local high_message_ids_length = 0

	for message_id, cursor_and_send_count in batched_cursor_and_send_count do
		if message_id <= LOW_MESSAGES_END then
			low_message_ids_length += 1
			low_message_ids[low_message_ids_length] = message_id
			allocate_low_message()
		else
			high_message_ids_length += 1
			high_message_ids[high_message_ids_length] = message_id
			allocate_high_message()
		end

		local cursor = cursor_and_send_count.x
		local send_count = cursor_and_send_count.y

		allocate_vlq(send_count)
		allocate_raw(cursor)
	end

	local low_exists = low_message_ids_length > 0
	local high_exists = high_message_ids_length > 0

	--[[
	message arrays are encoded optionally, don't alloc id count if there aren't any message ids
	]]
	if low_exists then allocate_vlq(low_message_ids_length) end
	if high_exists then allocate_vlq(high_message_ids_length) end

	return low_exists and low_message_ids or nil, high_exists and high_message_ids or nil
end

@native
local function allocate_bitpacks_and_get_opt_boundaries(
	message_bitpacks: { [MessageId]: Bitpacker },
	low_message_ids: { MessageId }?,
	high_message_ids: { MessageId }?
): { number }?
	local bitpack_boundary_array = {}
	local bitpack_boundary_array_length = 0

	local bound_contains_bitpack_data = false
	local bound_length = 0

	if low_message_ids ~= nil then
		local low_message_id_count = #low_message_ids
		for index = 1, low_message_id_count do
			local id = low_message_ids[index]
			local bitpacker = message_bitpacks[id]
			local contains_data = if bitpacker == nil then false else bitpack_contains_data(bitpacker)
			if contains_data then allocate_packer(bitpacker) end
			if contains_data == bound_contains_bitpack_data then
				bound_length += 1
			else
				bound_contains_bitpack_data = contains_data
				bitpack_boundary_array_length += 1
				bitpack_boundary_array[bitpack_boundary_array_length] = bound_length
				bound_length = 0
			end
		end
	end
	if high_message_ids ~= nil then
		local low_message_id_count = #high_message_ids
		for index = 1, low_message_id_count do
			local id = high_message_ids[index]
			local bitpacker = message_bitpacks[id]
			local contains_data = bitpack_contains_data(bitpacker)
			if contains_data then allocate_packer(bitpacker) end
			if contains_data == bound_contains_bitpack_data then
				bound_length += 1
			else
				bound_contains_bitpack_data = contains_data
				bitpack_boundary_array_length += 1
				bitpack_boundary_array[bitpack_boundary_array_length] = bound_length
				bound_length = 0
			end
		end
	end

	if bitpack_boundary_array_length == 0 then return nil end

	return bitpack_boundary_array
end

--[[
arr(vlq(3), vlq(3))
]]
local function allocate_bitpack_boundary_array(boundaries: { number }): ()
	local boundaries_len = #boundaries
	allocate_vlq(boundaries_len)

	for boundaries_index = 1, boundaries_len do
		local bound = boundaries[boundaries_index]

		allocate_vlq(bound)
	end
end

local function get_allocated_size(): number
	return allocated
end

local function reset_allocated_size(): ()
	allocated = 0
end

return {
	get_allocated_size = get_allocated_size,
	reset_allocated_size = reset_allocated_size,

	allocate_global_opts = allocate_global_opts,
	allocate_and_get_opt_message_id_maps = allocate_and_get_opt_message_id_maps,
	allocate_bitpacks_and_get_opt_boundaries = allocate_bitpacks_and_get_opt_boundaries,
	allocate_bitpack_boundary_array = allocate_bitpack_boundary_array,
}
