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
local holy = require("./holy")
local library_datatypes = require("./datatypes/main")
local message_id = require("./messages/id")
local message_types = require("./messages/types")

type HolyDatatype<T = any> = holy.Datatype<T>
type MessageId = message_types.MessageId

local ty = library_datatypes

local u8 = ty.u8

local str = ty.str
local range = ty.range
local struct = ty.struct
local arr = ty.arr

local function make_holy<Type>(Datatype: Type): holy.Datatype<Type>
	-- Luau
	return Datatype :: any
end

local internal_datatypes = {}

do -- messages
	local low_message =
		range(message_id.LOW_MESSAGES_START, message_id.LOW_MESSAGES_END) :: MessageId
	local high_message =
		range(message_id.HIGH_MESSAGES_START, message_id.HIGH_MESSAGES_END) :: MessageId
	local any_message =
		range(message_id.LOW_MESSAGES_START, message_id.HIGH_MESSAGES_END) :: MessageId

	local message_sync_one = struct({
		name = str(u8),
		message_id = any_message,
	})
	local message_sync_many = arr(message_sync_one, ty.vlq(3))

	internal_datatypes.low_message = make_holy(low_message)
	internal_datatypes.high_message = make_holy(high_message)
	internal_datatypes.any_message = make_holy(any_message)
	internal_datatypes.message_sync_one = make_holy(message_sync_one)
	internal_datatypes.message_sync_many = make_holy(message_sync_many)
end

return internal_datatypes
