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
local GLOBAL_NAMESPACE_NAME = "|_GLOBAL_|"

local holy = require("../../holy")
local message_types = require("../../messages/types")
local messages = require("../shared")
local report = require("../../report")

type HolyDatatype = holy.Datatype
type MessageId = message_types.MessageId

local existing_namespaces = {} :: { [string]: true? }

local function container_constructor(
	message_map: { [string]: HolyDatatype },
	namespace: string?
): { [string]: MessageId }
	local output_container = {}

	if namespace == nil then
		namespace = GLOBAL_NAMESPACE_NAME
	elseif namespace == GLOBAL_NAMESPACE_NAME then
		error(
			debug.traceback(`Cannot make namespace "{GLOBAL_NAMESPACE_NAME}", this name is reserved.`)
		)
	elseif existing_namespaces[namespace] then
		error(report.problem(`Attempted to create a namespace "{namespace}" that already existed.`))
	else
		existing_namespaces[namespace] = true
	end

	local prefix = `namespaces/{namespace}/`

	for name, message_format in message_map do
		output_container[name] = messages.new(`{prefix}{name}`, message_format)
	end

	return output_container
end

return container_constructor
