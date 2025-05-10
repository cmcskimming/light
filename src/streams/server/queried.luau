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
local new_stream = require("../constructor")
local stream_types = require("../types")

type Client = clients_types.Identity
type OutgoingStream = stream_types.OutgoingStream
type ClientSet = { [Client]: true? }

local client_is_connected = clients.is_connected

--- subscribed_client_sets_by_length stores a set of all connected clients subscribed to the queryable stream based on
--- the length of clients the queryable stream was constructed with.
local subscribed_client_sets_by_length = {} :: { [number]: { ClientSet } }
--- mapped_locators_by_length is a 1:1 map, matching the subscribed client sets, again, by length.
local mapped_locators_by_length = {} :: { [number]: { OutgoingStream } }

clients.client_removed:connect(function(client: Client): ()
	for client_count, stream_client_sets in subscribed_client_sets_by_length do
		local locator = mapped_locators_by_length[client_count]

		-- reverse iter since i call table.remove here
		for stream_client_sets_index = #stream_client_sets, 1, -1 do
			local stream_client_set = stream_client_sets[stream_client_sets_index]
			stream_client_set[client] = nil

			local stream_isnt_empty = next(stream_client_set)

			if stream_isnt_empty then continue end

			table.remove(stream_client_sets, stream_client_sets_index)
			table.remove(locator, stream_client_sets_index)
		end
	end
end)

--[[
This is a slow path, constructs a new stream from a list of players and makes it able to be queried.
]]
local function new_queried_stream(clients: { Client }): OutgoingStream?
	local clients_len = #clients

	if not clients[1] then return nil end

	local clients_as_set = {} :: { [Client]: true? }
	for clients_index = 1, clients_len do
		local client = clients[clients_index]

		if client_is_connected[client] then
			clients_as_set[client] = true --
		end
	end

	local stream_client_sets = subscribed_client_sets_by_length[clients_len]

	if stream_client_sets == nil then
		stream_client_sets = {}
		subscribed_client_sets_by_length[clients_len] = stream_client_sets
	end

	local stream_locator_table = mapped_locators_by_length[clients_len]

	if stream_locator_table == nil then
		stream_locator_table = {}
		mapped_locators_by_length[clients_len] = stream_locator_table
	end

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

	local stream_client_sets = subscribed_client_sets_by_length[clients_len]

	if stream_client_sets == nil then
		if clients_len == 0 then return nil end
		stream_client_sets = {}
		subscribed_client_sets_by_length[clients_len] = stream_client_sets
	end

	local stream_client_sets_len = #stream_client_sets

	for candidate_index = 1, stream_client_sets_len do
		local candidate_client_set = stream_client_sets[candidate_index]

		local candidate_matches_all_clients = true

		--[[
		Reverse iterating clients table, my thought here is that the "unique" clients are going to tend to be towards 
		]]
		for client_index = clients_len, 1, -1 do
			local selected_client = clients[client_index]

			-- do not run checks for clients that aren't ingame, as they get removed from the table
			if not client_is_connected[selected_client] then continue end

			if candidate_client_set[selected_client] ~= true then
				candidate_matches_all_clients = false
				break
			end
		end

		if not candidate_matches_all_clients then continue end

		local stream_locator_table = mapped_locators_by_length[clients_len]

		local outgoing_stream = stream_locator_table[candidate_index]

		return outgoing_stream
	end

	-- slowpath
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

	subscribed_client_sets_by_length = subscribed_client_sets_by_length,
	mapped_locators_by_length = mapped_locators_by_length,
}
