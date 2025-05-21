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
local clients_types = require("../../include/clients/types")
local internal_bridges = require("../../internal_bridges")
local light_types = require("../../types")
local server_message_queue = require("../../messages/server_queue")
local stream_import_iterator = require("../../streams/bridge_utils/import_iterator")

type Client = clients_types.Identity
type MessagingBridgeData = light_types.MessagingBridgeData

local message_callbacks = server_message_queue.callbacks
local message_queue_insert_many = server_message_queue.insert_many

local function process_incoming(client: Client, first: MessagingBridgeData, second: buffer?): ()
	local incoming_iterator
	if second ~= nil then
		-- Luau
		incoming_iterator = stream_import_iterator(second, first :: any)
	else
		-- Luau
		incoming_iterator = stream_import_iterator(first :: any)
	end

	for message_id, call_count, message_data_table in incoming_iterator do
		for data_index = 1, call_count do
			local callback = message_callbacks[message_id]
			if callback == nil then
				--[[
				message callback can't change from nil while inserting incoming data into the queue
				]]
				local start_insert = data_index
				local end_insert = call_count
				message_queue_insert_many(
					message_id,
					client,
					start_insert,
					end_insert,
					message_data_table
				)

				break
			end

			local message_data = message_data_table[data_index]
			callback(client, message_data)
		end
	end
end

--[=[
Start receiving reliable messages on the server.
]=]
local function init(): ()
	internal_bridges.to_server.reliable_messaging.server_event(process_incoming)
end

return {
	init = init,
}
