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
local holy = require("../../../holy")
local report = require("../../../report")

type HolyDatatype<T = any> = holy.Datatype<T>

local is_stfu = holy._is_stfu
local stfu_check = holy._stfu_check
local metadata = holy._datatype_metadata
local const_lookup_uint_type = holy.const_lookups.uint.type

local function identifier<Identifier>(identifiers: { Identifier }): HolyDatatype<Identifier>
	if #identifiers < 1 then
		error(report.problem("Error in Identifier Enum: Identifier list should not be empty"))
	end

	local identifier_id_to_identifier = table.clone(identifiers)
	local identifier_to_identifier_id = {} :: { [Identifier]: number }

	local number_eh: true? = true

	for identifier_id, identifier in identifier_id_to_identifier do
		if (type(identifier) == "table") and (is_stfu() == false) then
			warn(
				report.problem(
					`Enum[{identifier_id}] has Identifier: {identifier} where identifier is table.\n`
						.. [[
						This is probably a bug. Tables are only indexed in enums by direct memory reference.
						To silence this warning, use stfu(true):
						```luau
						stfu(true)
						local abc = enum({...})
						stfu(false)
						```
						]]
				)
			)
		elseif type(identifier) == "nil" then
			error(
				report.problem(
					`Invalid Identifir Enum: Enum{identifier_id} of enum is nil.`
						.. ` (maxn = {table.maxn(identifier_id_to_identifier)})`
						.. "\nIf this was intentional, please use an optional instead."
				)
			)
		end

		if type(identifier) ~= "number" then number_eh = nil end

		identifier_to_identifier_id[identifier] = identifier_id
	end

	local num_identifiers = #identifiers

	local identifier_enum_datatype = holy.new_datatype()

	local identifier_enum_ser_no_realloc, identifier_enum_ser_static, identifier_enum_ser, identifier_enum_des

	if num_identifiers == 1 then
		local single_identifier = identifiers[1]

		metadata.static_size[identifier_enum_datatype] = 0

		@native --dynamic_ncgen
		function identifier_enum_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): number
			if input ~= (single_identifier :: any) then
				stfu_check()
				error(
					report.problem(
						"Error serializing Identifier Enum.\n"
							.. `Mismatching Input: {input}`
							.. `\n\nExpected to match identifier: {single_identifier}`
					)
				)
			end

			return byte_ptr
		end

		@native --dynamic_ncgen
		function identifier_enum_ser_static(buff: buffer, byte_ptr: number, input: any): ()
			if input ~= (single_identifier :: any) then
				stfu_check()
				error(
					report.problem(
						"Error serializing Identifier Enum.\n"
							.. `Mismatching Input: {input}`
							.. `\n\nExpected to match identifier: {single_identifier}`
					)
				)
			end
		end

		@native --dynamic_ncgen
		function identifier_enum_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
			if input ~= (single_identifier :: any) then
				stfu_check()
				error(
					report.problem(
						"Error serializing Identifier Enum.\n"
							.. `Mismatching Input: {input}`
							.. `\n\nExpected to match identifier: {single_identifier}`
					)
				)
			end

			return byte_ptr, buff
		end

		@native --dynamic_ncgen
		function identifier_enum_des(buff: buffer, byte_ptr: number): (number, any)
			return byte_ptr, single_identifier
		end
	else
		local identifier_datatype_size = holy.uint_size(num_identifiers)
		local identifier_datatype = const_lookup_uint_type[identifier_datatype_size]

		local identifier_datatype_static_size = metadata.static_size[identifier_datatype]
		local identifier_datatype_ser_no_realloc = metadata.ser_no_realloc[identifier_datatype]
		local identifier_datatype_ser_static = metadata.ser_static[identifier_datatype]
		local identifier_datatype_des = metadata.des[identifier_datatype]

		metadata.static_size[identifier_enum_datatype] = identifier_datatype_static_size

		@native --dynamic_ncgen
		function identifier_enum_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): number
			local index = identifier_to_identifier_id[input]

			byte_ptr = identifier_datatype_ser_no_realloc(buff, byte_ptr, index)

			return byte_ptr
		end

		@native --dynamic_ncgen
		function identifier_enum_ser_static(buff: buffer, byte_ptr: number, input: any): ()
			local index = identifier_to_identifier_id[input]

			identifier_datatype_ser_static(buff, byte_ptr, index)
		end

		@native --dynamic_ncgen
		function identifier_enum_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
			local target_ptr = byte_ptr + identifier_datatype_static_size

			--stylua: ignore
			do
				local len = buffer.len(buff)
				if target_ptr > len then local old_buf = buff;len *= 2;while target_ptr > len do len *= 2;end;buff = buffer.create(len);buffer.copy(buff, 0, old_buf, 0, byte_ptr); end
			end
			local index = identifier_to_identifier_id[input]

			identifier_datatype_ser_static(buff, byte_ptr, index)

			return target_ptr, buff
		end

		@native --dynamic_ncgen
		function identifier_enum_des(buff: buffer, byte_ptr: number): (number, any)
			local identifier_id
			byte_ptr, identifier_id = identifier_datatype_des(buff, byte_ptr)

			local identifier = identifier_id_to_identifier[identifier_id]

			return byte_ptr, identifier
		end
	end

	metadata.is_number[identifier_enum_datatype] = number_eh

	metadata.ser_no_realloc[identifier_enum_datatype] = identifier_enum_ser_no_realloc
	metadata.ser_static[identifier_enum_datatype] = identifier_enum_ser_static
	metadata.ser[identifier_enum_datatype] = identifier_enum_ser
	metadata.des[identifier_enum_datatype] = identifier_enum_des

	return identifier_enum_datatype
end

return identifier
