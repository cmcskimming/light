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

type MessageId<MessageData = any> = message_types.MessageId<MessageData>
type Callback<MessageData = any> = message_types.ClientCallback<MessageData>

type QueuedMessages<MessageData = any> = {
	length: number,
	data: { MessageData },
}

local message_callbacks = {} :: { [MessageId]: Callback }

local message_queues = {} :: { [MessageId]: QueuedMessages }

local client_queue = {
	callbacks = message_callbacks,
}

--[=[
this logic is totally not a mess trust ahahaha
]=]
function client_queue.read<MessageData>(message_id: MessageId<MessageData>): () -> (true?, MessageData?)
	local queue = message_queues[message_id]
	if queue == nil then
		return function()
			return nil, nil
		end
	end

	local function queue_iterator<MessageData>(): (true?, MessageData?)
		local queue_length = queue.length

		if queue_length <= 0 then
			message_queues[message_id] = nil
			return nil, nil
		end

		local queue_data = queue.data

		local removed_data = table.remove(queue_data, 1)
		queue_length -= 1
		queue.length = queue_length

		return true, removed_data
	end

	return queue_iterator
end

function client_queue.insert_one<MessageData>(message_id: MessageId<MessageData>, data: MessageData): ()
	local queue = message_queues[message_id]

	if queue == nil then
		queue = {
			length = 1,
			data = { data },
		}
		message_queues[message_id] = queue
		return
	end

	local length = queue.length
	length += 1
	queue.length = length

	queue.data[length] = data
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
			data = {},
		}
		message_queues[message_id] = queue
	end

	local length = queue.length

	table.move(data_table, insert_start, insert_end, length + 1, queue.data)

	length += insert_end - insert_start + 1
	queue.length = length
end

return client_queue
