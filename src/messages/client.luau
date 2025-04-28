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
local datatype_cached = require("../datatypes/cached")
local holy = require("../holy")
local internal_bridges = require("../internal_bridges")
local internal_datatypes = require("../internal_datatypes")
local message_linking = require("./linking")
local message_types = require("./types")
local report = require("../report")
local task = require("../include/task/main.h")

local task_spawn = task.spawn

type HolyDatatype = holy.Datatype
type MessageId = message_types.MessageId

local des_message_sync = holy.fetch.des(internal_datatypes.message_sync_one)

local awaiting_sync = {} :: { [string]: thread }

local function message_constructor(
	message_name: string,
	datatype: datatype_cached.AcceptableSchema
): MessageId
	local message_id = message_linking.ids[message_name]

	if message_id ~= nil then
		message_linking.link_serdes(message_name, datatype)
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

	message_linking.link_serdes(message_name, datatype)

	return message_id
end

local function init_messages(): ()
	internal_bridges.to_client.sync_one_id.client_event(function(buff: buffer): ()
		local _, sync = des_message_sync(buff, 0)

		local message_name = sync.name
		local message_id = sync.message_id

		message_linking.link_name(message_name, message_id)

		local waiting_thread = awaiting_sync[message_name]

		if waiting_thread then
			task_spawn(waiting_thread, message_id)
			awaiting_sync[message_name] = nil
			return
		end
	end)
end

local client_messages = {
	init = init_messages,

	new = message_constructor,
}

return client_messages
