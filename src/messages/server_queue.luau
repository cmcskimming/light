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
local clients_types = require("../include/clients/types")
local message_types = require("./types")
local thread_reuse = require("../utils/thread_reuse")

type Client = clients_types.Identity
type MessageId<MessageData = any> = message_types.MessageId<MessageData>
type Callback<MessageData = any> = message_types.ServerCallback<MessageData>

local reused_spawn = thread_reuse.reused_spawn

type QueuedMessages<MessageData = any> = {
	length: number,
	clients: { Client },
	queued_data: { MessageData },
}

local message_callbacks = {} :: { [MessageId]: Callback }

local message_queues = {} :: { [MessageId]: QueuedMessages }

local server_queue = {
	callbacks = message_callbacks,
}

function server_queue.invoke<MessageData>(
	message_id: MessageId<MessageData>,
	message_callback: Callback<MessageData>
): ()
	local queue = message_queues[message_id]
	if queue == nil then return end
	message_queues[message_id] = nil

	local queue_clients = queue.clients
	local queue_data = queue.queued_data

	for queue_index = 1, queue.length do
		-- spawning in async to avoid invoking queue behaving unexpectedly
		reused_spawn(message_callback, queue_clients[queue_index], queue_data[queue_index])
	end
end

function server_queue.insert_one<MessageData>(
	message_id: MessageId<MessageData>,
	client: Client,
	data: MessageData
): ()
	local queue = message_queues[message_id]

	if queue == nil then
		queue = {
			length = 1,
			clients = { client },
			queued_data = { data },
		}
		message_queues[message_id] = queue
		return
	end

	local length = queue.length
	length += 1
	queue.length = length

	queue.queued_data[length] = data
	queue.clients[length] = client
end

function server_queue.insert_many<MessageData>(
	message_id: MessageId<MessageData>,
	client: Client,
	insert_start: number,
	insert_end: number,
	data_table: { MessageData }
): ()
	local queue = message_queues[message_id]

	local range = insert_end - insert_start + 1

	local client_table = table.create(range, client)

	if queue == nil then
		local queued_data = table.create(range) :: { MessageData }
		table.move(data_table, insert_start, insert_end, 1, queued_data)

		message_queues[message_id] = {
			length = range,
			clients = client_table,
			queued_data = queued_data,
		}

		return
	end

	local length: number = queue.length
	table.move(data_table, insert_start, insert_end, length + 1, queue.queued_data)
	table.move(client_table, 1, range, length + 1, queue.clients)
	length += range
	queue.length = length

	return
end

return server_queue
