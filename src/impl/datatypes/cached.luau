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
--!nolint LocalShadow
--!optimize 2
local datatypes = require("../../include/datatypes/main.h")
local datatypes_types = require("../../include/datatypes/types")
local holy = require("../../holy")
local report = require("../../report")

type AcceptableSchema = datatypes_types.AcceptableCachedSchema

local holy_datatypes = holy.datatypes

type HolyDatatype<T = any> = holy.Datatype<T>

--[=[
Converts Recursively:
```luau
type {Datatype<Item>} -- into arr(Datatype<Item>)
type {[Datatype<Key>]: Datatype<Value>} -- into map(Datatype<Key>, Datatype<Value>)
type {[string]: Datatype} -- into a struct
```
]=]
local function cached<Input>(input: AcceptableSchema): HolyDatatype<Input>
	local input_type = type(input)
	if input_type ~= "table" then
		if holy.check_datatype_exists(input) then return input :: any end
		error(report.problem(`Invalid Datatype: Datatype does not exist with id: {input}`))
	end

	local input = input :: { [unknown]: AcceptableSchema }

	local first_index, first_value = next(input)

	if first_index == 1 then return holy_datatypes.arr(cached(first_value)) end

	-- Luau
	local cached_first_index = cached(first_index :: any)

	local type_first_index = type(cached_first_index)

	if (type_first_index == "number") or (type_first_index == "vector") then
		return holy_datatypes.map(cached_first_index, cached(first_value))
	end

	local input = input :: { [string]: AcceptableSchema }

	local output = {} :: { [string]: any }

	for key, value in input do
		if type(key) ~= "string" then
			error(
				report.problem(
					`Invalid cached datatype: Expected a string at key "{key}", got type "{typeof(key)}"`
				)
			)
		end
		output[key] = cached(value)
	end

	return holy_datatypes.struct(output)
end

datatypes.cached = cached :: any

return nil
