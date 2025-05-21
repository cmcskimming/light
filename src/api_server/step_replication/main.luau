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
local clients = require("../../include/clients/main.h")
local clients_types = require("../../include/clients/types")
local export_stream = require("../../streams/bridge_utils/export")
local global_stream = require("../../streams/global_stream")
local internal_bridges = require("../../internal_bridges")
local light_types = require("../../types")
local queried_streams = require("../../streams/server/queried")
local reset_stream = require("../../streams/outgoing_reset")
local stream_types = require("../../streams/types")

type Client = clients_types.Identity
type OutgoingStream = stream_types.OutgoingStream
type MessagingBridgeData = light_types.MessagingBridgeData

local reliable_messaging = internal_bridges.to_client.reliable_messaging
local subscribed_client_sets_by_length = queried_streams.subscribed_client_sets_by_length
local mapped_locators_by_length = queried_streams.mapped_locators_by_length
local get_all_clients = clients.all_clients

local defer_reset = {} :: { [OutgoingStream]: true? }

local function global_replication(): { [Client]: { MessagingBridgeData } }?
	local batch_buff = export_stream(global_stream)

	if batch_buff == nil then return nil end

	local per_client_send_lists = {} :: { [Client]: { MessagingBridgeData } }

	local batch_unknown_len = global_stream.batch_unknown_len
	local should_insert_unknown = batch_unknown_len > 0
	local batch_unknown = global_stream.batch_unknown

	local all_clients = get_all_clients()
	local num_clients = #all_clients

	if should_insert_unknown then
		for clients_index = 1, num_clients do
			local client = all_clients[clients_index]

			per_client_send_lists[client] = { batch_unknown, batch_buff }
		end
	else
		for clients_index = 1, num_clients do
			local client = all_clients[clients_index]

			-- Luau
			local bridge_data: MessagingBridgeData = batch_buff

			per_client_send_lists[client] = { bridge_data }
		end
	end

	defer_reset[global_stream] = true

	return per_client_send_lists
end

local function step_replication(): ()
	local per_client_send_lists: { [Client]: { MessagingBridgeData } } = global_replication() or {}

	for client_count, stream_client_sets in subscribed_client_sets_by_length do
		local stream_locator_table = mapped_locators_by_length[client_count]

		for stream_client_sets_index = 1, #stream_client_sets do
			local outgoing_stream = stream_locator_table[stream_client_sets_index]

			local batch_buff = export_stream(outgoing_stream)

			if batch_buff == nil then continue end

			defer_reset[outgoing_stream] = true

			local batch_unknown_len = outgoing_stream.batch_unknown_len
			local should_insert_unknown = batch_unknown_len > 0
			local batch_unknown = outgoing_stream.batch_unknown

			local stream_client_set = stream_client_sets[stream_client_sets_index]

			for client in stream_client_set do
				local send_list = per_client_send_lists[client]
				if send_list == nil then
					send_list = {}
					per_client_send_lists[client] = send_list
				end

				if should_insert_unknown then table.insert(send_list, batch_unknown) end

				table.insert(send_list, batch_buff)
			end
		end
	end

	for client, send_table in per_client_send_lists do
		reliable_messaging.fire_client(client, table.unpack(send_table))
	end

	if not next(defer_reset) then return end

	for to_reset in defer_reset do
		reset_stream(to_reset)
	end

	-- Luau
	defer_reset = {} :: any
end

return step_replication
