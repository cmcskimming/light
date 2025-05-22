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
do
end
local _datatype_cached = require("../cached.api")
local datatypes = require("../../../include/datatypes/main.h")
local holy = require("../../../holy")
local report = require("../../../report")

type HolyDatatype<T = any> = holy.Datatype<T>
type Ser<T = any> = holy.Ser<T>
type Des<T = any> = holy.Des<T>

local ty = holy.datatypes
local metadata = holy._datatype_metadata
local const = holy.const_lookups

export type function tagged_enum(tag: type, identifier_map: type): type
	assert(identifier_map:is("table"), "Must take in a table datatype")
	assert(tag:is("singleton"), "Tag must be a singleton")
	assert(type(tag:value()) == "string", "Tag must be a string singleton")

	local props = identifier_map:properties()

	local output = {}

	for key, readwrite in props do
		local read = readwrite.read :: type

		if not read:is("table") then
			error(`Expected a "table" at key "{key:value()}" of identifier map, got tag "{read.tag}"`)
		end

		read:setproperty(tag, key)

		table.insert(output, read)
	end

	return types.unionof(unpack(output))
end

local function tagged<IdentifierName, Identifier, PossibleData>(
	identifier_name: IdentifierName,
	identifier_map: {
		[Identifier]: HolyDatatype<PossibleData>,
	}
): HolyDatatype<
	PossibleData & { [IdentifierName]: Identifier }
>
	local tagged_enum_datatype = holy.new_datatype()

	local identifier_to_id = {} :: { [Identifier]: number }

	local id_to_ser = {} :: { [Identifier]: Ser<PossibleData> }

	local id_to_identifier = {} :: { [number]: Identifier }

	local id_to_des = {} :: { [number]: Des<PossibleData> }

	local id = 0
	for identifier_value, identifier_struct in identifier_map do
		-- Luau
		if type(identifier_struct :: {}) ~= "table" then
			error(
				report.problem(
					`Invalid Tagged Enum: Identifier "{identifier_value}" was not 'table'.`
						.. ` type: {typeof(identifier_value)}`
				)
			)
		end

		local cloned_template: HolyDatatype<PossibleData> & { [IdentifierName]: Identifier } =
			table.clone(identifier_struct) :: any

		for index, value in identifier_struct do
			local cached_value = datatypes.cached(value)
			cloned_template[index] = cached_value
		end

		cloned_template[identifier_name] = ty.literal(identifier_value)

		local template_datatype = ty.struct(cloned_template)

		local template_ser = metadata.ser[template_datatype]
		local template_des = metadata.des[template_datatype]

		identifier_to_id[identifier_value] = id
		id_to_identifier[id] = identifier_value
		id_to_ser[id] = template_ser
		id_to_des[id] = template_des

		id += 1
	end

	local identifier_bytes = holy.uint_size(id - 1)
	local ser_identifier_id = const.uint.ser[identifier_bytes]
	local des_identifier_id = const.uint.des[identifier_bytes]

	@native --dynamic_ncgen
	local function tagged_enum_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
		local identifier_value = input[identifier_name]

		local identifier_id = identifier_to_id[identifier_value]

		byte_ptr, buff = ser_identifier_id(buff, byte_ptr, identifier_id)

		local ser_for_identifier = id_to_ser[identifier_id]

		byte_ptr, buff = ser_for_identifier(buff, byte_ptr, input)

		return byte_ptr, buff
	end

	@native --dynamic_ncgen
	local function tagged_enum_des(buff: buffer, byte_ptr: number): (number, PossibleData)
		local identifier_value
		byte_ptr, identifier_value = des_identifier_id(buff, byte_ptr)

		local des_for_identifier = id_to_des[identifier_value]

		local output
		byte_ptr, output = des_for_identifier(buff, byte_ptr)

		return byte_ptr, output
	end

	metadata.ser[tagged_enum_datatype] = tagged_enum_ser
	metadata.des[tagged_enum_datatype] = tagged_enum_des

	return tagged_enum_datatype
end

return tagged
