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
local holy = require("../holy")
local imported_any = require("./any")
local report = require("../report")

type HolyDatatype<T = any> = holy.Datatype<T>

local metadata = holy._datatype_metadata

local any_ser_no_realloc = metadata.ser_no_realloc[imported_any]
local any_ser_static = metadata.ser_static[imported_any]
local any_ser = metadata.ser[imported_any]
local any_des = metadata.des[imported_any]
local any_static_size = metadata.static_size[imported_any]

if any_static_size == nil then
	error(report.bug(report.problem("Could not fetch static size for any")))
end

local function checked<Input, Checked>(sanity_check: (Input) -> Checked): HolyDatatype<Checked>
	local checked_datatype = holy.new_datatype(any_static_size)

	local function checked_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): number
		input = sanity_check(input)

		return any_ser_no_realloc(buff, byte_ptr, input)
	end

	local function checked_ser_static(buff: buffer, byte_ptr: number, input: any): ()
		input = sanity_check(input)

		return any_ser_static(buff, byte_ptr, input)
	end

	local function checked_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
		input = sanity_check(input)

		return any_ser(buff, byte_ptr, input)
	end

	local function checked_des(buff: buffer, byte_ptr: number): (number, any)
		local output
		byte_ptr, output = any_des(buff, byte_ptr)

		output = sanity_check(output)

		return byte_ptr, output
	end

	metadata.ser_no_realloc[checked_datatype] = checked_ser_no_realloc
	metadata.ser_static[checked_datatype] = checked_ser_static
	metadata.ser[checked_datatype] = checked_ser
	metadata.des[checked_datatype] = checked_des

	return checked_datatype
end

return checked
