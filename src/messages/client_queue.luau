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
--!optimize 2
local message_types = require("./types")
local thread_reuse = require("../utils/thread_reuse")

type MessageId<MessageData = any> = message_types.MessageId<MessageData>
type Callback<MessageData = any> = message_types.ClientCallback<MessageData>

local reused_spawn = thread_reuse.reused_spawn

type QueuedMessages<MessageData = any> = {
	length: number,
	queued_data: { MessageData },
}

local message_callbacks = {} :: { [MessageId]: Callback }

local message_queues = {} :: { [MessageId]: QueuedMessages }

local client_queue = {
	callbacks = message_callbacks,
}

function client_queue.invoke<MessageData>(
	message_id: MessageId<MessageData>,
	message_callback: Callback<MessageData>
): ()
	local queue = message_queues[message_id]
	if queue == nil then return end
	message_queues[message_id] = nil

	local queue_data = queue.queued_data

	for queue_index = 1, queue.length do
		-- spawning in async to avoid invoking queue behaving unexpectedly
		reused_spawn(message_callback, queue_data[queue_index])
	end
end

function client_queue.insert_one<MessageData>(message_id: MessageId<MessageData>, data: MessageData): ()
	local queue = message_queues[message_id]

	if queue == nil then
		queue = {
			length = 1,
			queued_data = { data },
		}
		message_queues[message_id] = queue
		return
	end

	local length = queue.length
	length += 1
	queue.length = length

	queue.queued_data[length] = data
end

function client_queue.insert_many<MessageData>(
	message_id: MessageId<MessageData>,
	insert_start: number,
	insert_end: number,
	data_table: { MessageData }
): ()
	local queue = message_queues[message_id]

	if queue == nil then
		queue = {
			length = 0,
			queued_data = {},
		}
		message_queues[message_id] = queue
	end

	local length: number = queue.length
	length += 1
	queue.length = length

	table.move(data_table, insert_start, insert_end, length, queue.queued_data)
end

return client_queue
