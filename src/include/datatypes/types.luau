local holy = require("../../holy")

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

export type function tagged_enum(tag: type, identifier_map: type)
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

return nil
