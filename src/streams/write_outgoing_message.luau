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
local bitpack = require("../bitpack")
local holy = require("../holy")
local message_types = require("../messages/types")
local outgoing_state = require("./outgoing_state")
local stream_constants = require("./constants")
local stream_types = require("./types")

type HolySerFunctions = typeof(holy._datatype_metadata.ser)
type MessageId = message_types.MessageId
type OutgoingStream = stream_types.OutgoingStream
type Bitpacker = bitpack.Identity

local DEFAULT_MESSAGE_BUFF_SIZE = stream_constants.DEFAULT_MESSAGE_BUFF_SIZE
local metadata = holy._datatype_metadata
local ser = metadata.ser
local new_bitpack = bitpack.new

type MessageBitpacks = index<OutgoingStream, "message_bitpacks">
type MessageBuffs = index<OutgoingStream, "message_buffs">
type BatchedCursorAndSendCount = index<OutgoingStream, "batched_cursor_and_send_count">

type MessageBitpack = index<MessageBitpacks, MessageId>
type MessageBuff = index<MessageBuffs, MessageId>
type MessageSerializer = index<HolySerFunctions, keyof<HolySerFunctions>>

--[[
caching to avoid indexing every message write
]]
local cached_stream: OutgoingStream?
local message_bitpacks: MessageBitpacks
local message_buffs: MessageBuffs
local batched_cursor_and_send_count: BatchedCursorAndSendCount

local cached_message_id: MessageId?
local message_bitpack: MessageBitpack
local message_buff: index<typeof(message_buffs), keyof<typeof(message_buffs)>>
local message_serializer: index<typeof(ser), keyof<typeof(ser)>>

local function cache_stream(stream: OutgoingStream): ()
	-- print("caching stream", stream)
	cached_stream = stream

	message_bitpacks = stream.message_bitpacks

	message_buffs = stream.message_buffs

	batched_cursor_and_send_count = stream.batched_cursor_and_send_count

	outgoing_state._current_outgoing = stream
end

local function cache_message_id(message_id: MessageId): ()
	-- print("caching message id", message_id)
	cached_message_id = message_id

	-- Luau
	message_serializer = ser[message_id :: any]

	message_bitpack = message_bitpacks[message_id]
	-- Luau
	if (message_bitpack :: any) == nil then
		message_bitpack = new_bitpack()
		message_bitpacks[message_id] = message_bitpack
	end
	outgoing_state._current_bitpack = message_bitpack

	message_buff = message_buffs[message_id]
	-- Luau
	if (message_buff :: any) == nil then
		message_buff = buffer.create(DEFAULT_MESSAGE_BUFF_SIZE) --
		message_buffs[message_id] = message_buff
	end
end

local function write_outgoing_message(message_id: MessageId, stream: OutgoingStream, data: any): ()
	if stream ~= cached_stream then
		cache_stream(stream)
		cache_message_id(message_id)
	elseif message_id ~= cached_message_id then
		cache_message_id(message_id)
	end

	local cursor_and_send_count = batched_cursor_and_send_count[message_id]

	-- Luau
	if (cursor_and_send_count :: any) == nil then
		cursor_and_send_count = vector.create(0, 0) --
	end

	local cursor = cursor_and_send_count.x
	local send_count = cursor_and_send_count.y

	local new_msg_buff
	cursor, new_msg_buff = message_serializer(message_buff, cursor, data)

	send_count += 1

	if new_msg_buff ~= message_buff then
		message_buffs[message_id] = new_msg_buff --
	end

	batched_cursor_and_send_count[message_id] = vector.create(cursor, send_count)
end

return write_outgoing_message
