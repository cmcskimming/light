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
TODO: Clean-up this file
]]
local clients = require("../../include/clients/main.h")
local clients_types = require("../../include/clients/types")
local new_stream = require("../constructor")
local stream_types = require("../types")

type Client = clients_types.Identity
type OutgoingStream = stream_types.OutgoingStream
type ClientSet = { [Client]: true? }

local client_is_connected = clients.is_connected

local stream_client_sets_per_len = setmetatable({}, {
	__index = function(self: any, index: number): { ClientSet }
		local client_sets = {} :: { ClientSet }

		self[index] = client_sets

		return client_sets
	end,
}) :: { [number]: { ClientSet } }

local stream_locators_per_len = setmetatable({}, {
	__index = function(self: any, index: number): { OutgoingStream }
		local outgoing_streams = {}

		self[index] = outgoing_streams

		return outgoing_streams
	end,
}) :: { [number]: { OutgoingStream } }

clients.client_removed:connect(function(client: Client): ()
	for client_count, stream_client_set in stream_client_sets_per_len do
		local streams_len = #stream_client_set

		for streams_index = streams_len, 1, -1 do
			local stream = stream_client_set[streams_index]
			stream[client] = nil

			if next(stream) then continue end

			table.remove(stream_client_set, streams_index)
		end
	end
end)

--[[
This is a slow path, constructs a new stream from a list of players and makes it able to be queried.
]]
local function new_queried_stream(clients: { Client }): OutgoingStream?
	local clients_len = #clients

	local clients_as_set = {} :: { [Client]: true? }
	for clients_index = 1, clients_len do
		local client = clients[clients_index]

		if client_is_connected[client] then
			clients_as_set[client] = true --
		end
	end
	if not next(clients_as_set) then return nil end

	local stream_client_sets = stream_client_sets_per_len[clients_len]

	local stream_locator_table = stream_locators_per_len[clients_len]

	local num_existing_streams = #stream_client_sets

	local new_index = num_existing_streams + 1

	local output = new_stream()

	stream_client_sets[new_index] = clients_as_set
	stream_locator_table[new_index] = output

	return output
end

@native
local function query(clients: { Client }): OutgoingStream?
	local clients_len = #clients

	local stream_client_sets = stream_client_sets_per_len[clients_len]

	local stream_client_sets_len = #stream_client_sets

	for candidate_index = 1, stream_client_sets_len do
		local candidate_client_set = stream_client_sets[candidate_index]

		local has_all_members = true

		for client_index = 1, clients_len do
			local selected_client = clients[client_index]

			-- do not run checks for clients that aren't ingame, as they get removed from the table
			if client_is_connected[selected_client] ~= true then continue end

			if candidate_client_set[selected_client] ~= true then
				has_all_members = false
				break
			end
		end

		if has_all_members then
			local stream_locator_table = stream_locators_per_len[stream_client_sets_len]

			local outgoing_stream = stream_locator_table[candidate_index]

			return outgoing_stream
		end
	end

	return new_queried_stream(clients)
end

local per_client_streams = setmetatable({}, {
	__index = function(self: any, client: Client): OutgoingStream?
		if client_is_connected[client] then
			local new_stream = new_queried_stream({ client })
			self[client] = new_stream
			return new_stream
		end
		return nil
	end,
}) :: { [Client]: OutgoingStream? }

clients.client_removed:connect(function(client: Client): ()
	per_client_streams[client] = nil
end)

return {
	query = query,
	per_client_streams = per_client_streams,
}
