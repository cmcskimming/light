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
local datatypes = require("../include/datatypes/main.h")
local datatypes_types = require("../include/datatypes/types")
local holy = require("../holy")
local message_types = require("./types")
local report = require("../report")

local metadata = holy._datatype_metadata

type MessageId = message_types.MessageId
type HolyDatatype<T = any> = holy.Datatype<T>

local message_ids = {} :: { [string]: MessageId }
local message_names = {} :: { [MessageId]: string }
local message_ser = {} :: { [MessageId]: holy.Ser }
local message_des = {} :: { [MessageId]: holy.Des }

local function link_name(name: string, id: MessageId): ()
	message_ids[name] = id
	message_names[id] = name
end

local function link_serdes(
	message_name: string,
	input_type: datatypes_types.AcceptableCachedSchema
): ()
	local cached = datatypes.cached(input_type)

	if holy.check_datatype_exists(cached) == false then
		error(
			report.problem(
				`Expected datatype for message of name "{message_name}" to exist, got id "{cached}"`
					.. `\nDid you write your message definitions correctly?`
			)
		)
	end

	-- Luau (Nominal)
	local message_id: HolyDatatype = message_ids[message_name] :: any

	if message_id == nil then
		error(report.problem(`No message id found for message name "{message_name}"`))
	elseif message_ser[message_id] then
		error(
			report.problem(
				`Serialization already existed for message name "{message_name}"`
					.. `\nDid you try to redefine a message with that name? Message ID: {message_id}`
			)
		)
	elseif message_des[message_id] then
		error(
			report.problem(
				`Deserialization already existed for message name "{message_name}"`
					.. `\nDid you try to redefine a message with that name? Message ID: {message_id}`
			)
		)
	end

	-- Luau
	holy.copy_datatype(cached :: any, message_id)

	message_ser[message_id] = metadata.ser[message_id]
	message_des[message_id] = metadata.des[message_id]
end

return {
	link_name = link_name,
	link_serdes = link_serdes,

	ids = message_ids,
	names = message_names,
	ser = message_ser,
	des = message_des,
}
