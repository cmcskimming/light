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
local clients = require("../include/clients/main.h")
local clients_types = require("../include/clients/types")
local datatypes = require("../include/datatypes/main.h")
local datatypes_types = require("../include/datatypes/types")
local holy = require("../holy")
local id = require("./id")
local internal_bridges = require("../internal_bridges")
local internal_datatypes = require("../internal_datatypes")
local message_metadata_linking = require("./metadata_linking")
local message_queue = require("./server_queue")
local message_types = require("./types")
local report = require("../report")
local thread_reuse = require("../utils/thread_reuse")

type HolyDatatype = holy.Datatype
type Client = clients_types.Identity
type MessageId<T = any> = message_types.MessageId<T>
type Callback<T = any> = message_types.ServerCallback<T>

local reused_spawn = thread_reuse.reused_spawn
local invoke_message_queue = message_queue.invoke
local callbacks = message_queue.callbacks

local send_message_sync_one
local send_message_sync_all
do
	local sync_one_bridge = internal_bridges.to_client.sync_one_id
	local sync_many_bridge = internal_bridges.to_client.sync_many_ids

	local ser_one_message_sync = holy.fetch.ser(internal_datatypes.message_sync_one)
	local ser_many_messages_sync = holy.fetch.ser(internal_datatypes.message_sync_many)

	function send_message_sync_one(message_name: string, message_id: MessageId): ()
		local byte_ptr, raw_buff = ser_one_message_sync(buffer.create(48), 0, {
			message_id = message_id,
			name = message_name,
		})

		local buff = buffer.create(byte_ptr)

		buffer.copy(buff, 0, raw_buff, 0, byte_ptr)

		sync_one_bridge.fire_all_clients(buff)
	end
	function send_message_sync_all(client: Client): ()
		local sync_batch = {} :: typeof(holy.export(internal_datatypes.message_sync_many))

		for message_name, message_id in message_metadata_linking.ids do
			table.insert(sync_batch, {
				message_id = message_id,
				name = message_name,
			})
		end

		local byte_ptr, raw_buff = ser_many_messages_sync(buffer.create(48), 0, sync_batch)

		local buff = buffer.create(byte_ptr)

		buffer.copy(buff, 0, raw_buff, 0, byte_ptr)

		sync_many_bridge.fire_client(client, buff)
	end
end

local function message_constructor(
	message_name: string,
	datatype: datatypes_types.AcceptableCachedSchema
): MessageId
	local cached_datatype = datatypes.cached(datatype)

	local message_id = id.new()

	message_metadata_linking.link_name(message_name, message_id)
	message_metadata_linking.link_serdes(message_name, cached_datatype)

	send_message_sync_one(message_name, message_id)

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
	local function async_connection_wrapper(client: Client, data: MessageData): ()
		reused_spawn(callback, client, data)
	end

	sync_connection(message_id, async_connection_wrapper)
end

local function disconnect<MessageData>(message_id: MessageId<MessageData>): Callback<MessageData>?
	local existing_callback = callbacks[message_id]

	callbacks[message_id] = nil

	return existing_callback
end

clients.client_added:connect(send_message_sync_all)

local server_messages = {
	new = message_constructor,

	sync_connect = sync_connection,
	async_connect = async_connection,
	disconnect = disconnect,
}

return server_messages
