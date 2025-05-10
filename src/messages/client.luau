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
local datatypes = require("../include/datatypes/main.h")
local datatypes_types = require("../include/datatypes/types")
local holy = require("../holy")
local internal_bridges = require("../internal_bridges")
local internal_datatypes = require("../internal_datatypes")
local message_metadata_linking = require("./metadata_linking")
local message_queue = require("../messages/client_queue")
local message_types = require("./types")
local report = require("../report")
local task = require("../include/task/main.h")
local thread_reuse = require("../utils/thread_reuse")

type HolyDatatype = holy.Datatype
type MessageId<T = any> = message_types.MessageId<T>
type Callback<T = any> = message_types.ClientCallback<T>

local reused_spawn = thread_reuse.reused_spawn
local invoke_message_queue = message_queue.invoke
local task_spawn = task.spawn
local callbacks = message_queue.callbacks
local message_sync_one = internal_datatypes.message_sync_one
local message_sync_many = internal_datatypes.message_sync_many

local des_message_sync_one = holy.fetch.des(message_sync_one)
local des_message_sync_many = holy.fetch.des(message_sync_many)

local awaiting_sync = {} :: { [string]: thread }

local function message_constructor(
	message_name: string,
	datatype: datatypes_types.AcceptableCachedSchema
): MessageId
	local cached_datatype = datatypes.cached(datatype)

	local message_id = message_metadata_linking.ids[message_name]

	if message_id ~= nil then
		message_metadata_linking.link_serdes(message_name, cached_datatype)
		return message_id
	end

	do
		local waiting_thread = awaiting_sync[message_name]

		if waiting_thread ~= nil then
			error(
				report.bug(
					report.problem(
						`Message of name "{message_name}" is being awaited in multiple threads.`
					)
				)
			)
		end

		local running = coroutine.running()

		awaiting_sync[message_name] = running

		message_id = coroutine.yield()
	end

	message_metadata_linking.link_serdes(message_name, cached_datatype)

	return message_id
end

local function sync_connection<MessageData>(
	message_id: MessageId<MessageData>,
	callback: Callback<MessageData>
): ()
	local existing_callback = callbacks[message_id]

	if existing_callback then
		error(
			report.problem(
				`Message of id {message_id} already has a connection, `
					.. "consider using light.disconnect(message)"
			)
		)
	end

	callbacks[message_id] = callback

	invoke_message_queue(message_id, callback)
end

local function async_connection<MessageData>(
	message_id: MessageId<MessageData>,
	callback: Callback<MessageData>
): ()
	local function async_connection_wrapper(data: MessageData): ()
		reused_spawn(callback, data)
	end

	sync_connection(message_id, async_connection_wrapper)
end

local function disconnect<MessageData>(message_id: MessageId<MessageData>): Callback<MessageData>?
	local existing_callback = callbacks[message_id]

	callbacks[message_id] = nil

	return existing_callback
end

local function sync_message_from_remote(sync: typeof(holy.export(message_sync_one))): ()
	local message_name = sync.name
	local message_id = sync.message_id

	message_metadata_linking.link_name(message_name, message_id)

	local waiting_thread = awaiting_sync[message_name]

	if waiting_thread then
		task_spawn(waiting_thread, message_id)
		awaiting_sync[message_name] = nil
		return
	end
end

internal_bridges.to_client.sync_one_id.client_event(function(buff: buffer): ()
	local _, decoded_sync = des_message_sync_one(buff, 0)
	sync_message_from_remote(decoded_sync)
end)
internal_bridges.to_client.sync_many_ids.client_event(function(buff: buffer): ()
	local _, decoded_list = des_message_sync_many(buff, 0)
	for a, decoded_sync in decoded_list do
		sync_message_from_remote(decoded_sync)
	end
end)

local client_messages = {
	new = message_constructor,

	sync_connect = sync_connection,
	async_connect = async_connection,
	disconnect = disconnect,
}

return client_messages
