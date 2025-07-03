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
local holy = require("../../utils/holy")

type HolyDatatype<T = any> = holy.Datatype<T>

export type Datatype<T = any> = T

export type AcceptableCachedSchema =
	-- raw datatype (already cached)
	| HolyDatatype<any>
	-- arrays
	| { AcceptableCachedSchema }
	-- maps
	| { [AcceptableCachedSchema]: AcceptableCachedSchema }
	-- structs
	| { [string]: AcceptableCachedSchema }

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

type function recursive(Input: type, Id: type): type
	local value = Id.value

	local input_tag = Input.tag
	local id_value = value(Id)

	if input_tag == "singleton" then
		if value(Input) == id_value then return Id end
	elseif input_tag == "table" then
		local output = types.newtable()

		for index, readwrite in Input:properties() do
			local read = readwrite.read
			if read == nil then continue end
			read = recursive(read, Id)
			output:setproperty(index, read)
		end

		return output
	elseif input_tag == "union" then
		local components = Input:components()
		local components_len = #components
		local output_components = table.create(components_len)
		for component_index = 1, components_len do
			local Component = recursive(components[component_index], Id)
			table.insert(output_components, Component)
		end
		return types.unionof(table.unpack(output_components))
	elseif input_tag == "intersection" then
		local components = Input:components()
		local components_len = #components
		local output_components = table.create(components_len)
		for component_index = 1, components_len do
			local Component = recursive(components[component_index], Id)
			table.insert(output_components, Component)
		end
		return types.intersectionof(table.unpack(output_components))
	end

	return Input
end

export type Recursive<Input, Id> = recursive<Input, Id>

return nil
