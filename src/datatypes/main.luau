--!optimize 2
--!nolint LocalShadow

--[[TODO
move some of the docs from this file to the mkdocs and typescript stuff. The docs are much better here.
]]

local holy = require("../holy")
local instance_classes = require("./instance_class_types")

export type HolyDatatype<T = any> = holy.Datatype<T>
export type Datatype<T = any> = T

export type AcceptableSchema =
	-- raw datatype (cached)
	| HolyDatatype<any>
	-- arrays
	| { AcceptableSchema }
	-- maps
	| { [AcceptableSchema]: AcceptableSchema }
	-- structs
	| { [string]: AcceptableSchema }

type function tagged_enum(tag: type, identifier_map: type)
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

local holy_datatypes = holy.datatypes

local datatypes = {}

--[[-inline-documentation-is-my-passion-inline-documentation-is-my-passion-inline-documentation-is-my-passion-----------
Blank functions for user-facing types / documentation. Functions are defined with their real type inputs, then the
documented functions get replaced. This makes it very easy to have an internal datatype definition for this file, and
LSP function documentation.
-inline-documentation-is-my-passion-inline-documentation-is-my-passion-inline-documentation-is-my-passion-------------]]
do
	local function ERR(): any
		error(debug.traceback([[
		Attempt to call placeholder. Please report this as a bug on the github:
		https://github.com/hardlyardi/light/issues
		]]))
	end

	--[=[
	In light, you can use luau
	[`arrays`](https://light.ardi.gg/api/datatypes/generics/tables/arr/),
	[`maps`](https://light.ardi.gg/api/datatypes/generics/tables/map/),
	and [`structs`](https://light.ardi.gg/api/datatypes/generics/tables/struct/) to define a message Datatype.

	This API exists to recursively cache the result of a Datatype. This will internally turn it into a numeric ID if it
	isn't one already, rendering it unusable for anything other than ser/des and messages. Messages cache their Datatypes
	automatically, but this can be useful in conjunction with other features like
	[Computed Datatypes](https://light.ardi.gg/api/datatypes/generics/computed/).

	```luau
	function cached<T>(--Sync--
		value: Datatype<T>
	): Datatype<T>
	```

	[Learn More](https://light.ardi.gg/api/datatypes/generics/cached/)
	]=]
	function datatypes.cached<Input>(schema: Input): Datatype<Input>
		return ERR()
	end

	--[=[
	Arrays take in a datatype for what kind of item they should use, and an optional datatype for length which defaults
	to [`u16`](https://light.ardi.gg/api/datatypes/numbers/uints/). The length datatype should NOT be a regular
	number—instead: use a datatype that represents a number, like a
	[`uint`](https://light.ardi.gg/api/datatypes/numbers/uints/), or
	[`range`](https://light.ardi.gg/api/datatypes/generics/range/).

	```luau
	function arr<Item>(--Sync--
		item: Datatype<Item>,
		length: Datatype<number>?
	): Datatype<{ Item }>
	```

	[Learn More](https://light.ardi.gg/api/datatypes/generics/tables/arr/)
	]=]
	function datatypes.arr<Item>(
		item_datatype: Datatype<Item>,
		length_datatype: Datatype<number>?
	): Datatype<{ Item }>
		return ERR()
	end

	--[=[
	Maps take in a datatype for their key, a datatype for their value, and an optional datatype for length which defaults
	to [`u16`](https://light.ardi.gg/api/datatypes/numbers/uints/). The length datatype should NOT be a regular
	number—instead: use a datatype that represents a number, like a
	[`uint`](https://light.ardi.gg/api/datatypes/numbers/uints/), or
	[`range`](https://light.ardi.gg/api/datatypes/generics/range/).

	```luau
	function map<Key, Value>(--Sync--
		key: Datatype<Key>,
		value: Datatype<Value>,
		length: Datatype<number>?
	): Datatype<{ [Key]: Value }>
	```

	[Learn More](https://light.ardi.gg/api/datatypes/generics/tables/map/)
	]=]
	function datatypes.map<Key, Value>(
		key_datatype: Datatype<Key>,
		value_datatye: Datatype<Value>,
		length_datatype: Datatype<number>?
	): Datatype<{ [Key]: Value }>
		return ERR()
	end

	--[=[
	Structs are a fixed set of string keys and values.
	Structs are not guaranteed to have the field order you defined them with, but ordering is identical on client and
	server.

	```luau
	function struct<Fields>(--Sync--
		map: Fields -- { [string]: Datatype }
	): Datatype<Fields>
	```

	[Learn More](https://light.ardi.gg/api/datatypes/generics/tables/struct/)
	]=]
	function datatypes.struct<Fields>(map: Fields): Datatype<Fields>
		return ERR()
	end

	--[=[
	Variable Length Quantities allow you to encode a number which takes more space as it gets bigger. Includes an
	optional max_bytes, which will default to 7.

	```luau
	function vlq(--Sync--
		max_bytes: number?
	): Datatype<number>
	```
	]=]
	function datatypes.vlq(max_bytes: number?): Datatype<number>
		return ERR()
	end

	--[=[
	Create an Optional version of a datatype. This means it can be nil. This is most useful in a
	[`struct`](http://light.ardi.gg/api/datatypes/generics/tables/struct/), where you might not want or need all fields
	to exist in the data you're sending.

	```luau
	function optional<Inner>(--Sync--
		inner: Datatype<Inner>
	): Datatype<Inner?>
	```

	[Learn More](https://light.ardi.gg/api/datatypes/generics/optional/)
	]=]
	function datatypes.optional<Inner>(inner_datatype: Datatype<Inner>): Datatype<Inner?>
		return ERR()
	end

	--[=[
	Represents a string value. Includes an optional Datatype for length, which defaults
	to [`vlq(3)`](https://light.ardi.gg/api/datatypes/generics/vlq). The length datatype should NOT be a regular
	number—instead: use a datatype that represents a number, like a
	[`uint`](https://light.ardi.gg/api/datatypes/numbers/uints/), or
	[`range`](https://light.ardi.gg/api/datatypes/generics/range/).

	```luau
	function str(--Sync--
		length: Datatype<number>?
	): Datatype<string>
	```

	[Learn More](https://light.ardi.gg/api/datatypes/generics/str/)
	]=]
	function datatypes.str(length_datatype: Datatype<number>?): Datatype<string>
		return ERR()
	end

	--[=[
	Represents a range of possible [`uints`](https://light.ardi.gg/api/datatypes/numbers/uints) by providing a minimum
	and maximum value. If you input a number which is larger or smaller than the range, the number will always be clamped
	to fit the range.

	```luau
	function range(--Sync--
		minimum: number,
		maximum: number
	): Datatype<number>
	```

	[Learn More](https://light.ardi.gg/api/datatypes/generics/range/)
	]=]
	function datatypes.range(minimum: number, maximum: number): Datatype<number>
		return ERR()
	end
	
	--[=[
	Represents a 3 component luau vector. Includes optional `coord` parameter for the datatype each coordinate will use,
	defaulting to an [f32](https://light.ardi.gg/api/datatypes/numbers/floats/). It is worth noting that an
	[`f64`](https://light.ardi.gg/api/datatypes/numbers/floats/) Datatype's precision won't apply to a vector, and
	[`f32`](https://light.ardi.gg/api/datatypes/numbers/floats/) is always a better choice.

	```luau
	function vect3(--Sync--
		coord: Datatype<number>?
	): Datatype<vector>
	```

	[Learn More](https://light.ardi.gg/api/datatypes/generics/vect3/)
	]=]
	function datatypes.vect3(coord_datatype: Datatype<number>?): Datatype<vector>
		return ERR()
	end

	--[=[
	Represents a 2 component luau vector. Includes optional `coord` parameter for the datatype each coordinate will use,
	defaulting to an [f32](https://light.ardi.gg/api/datatypes/numbers/floats/). It is worth noting that an
	[`f64`](https://light.ardi.gg/api/datatypes/numbers/floats/) Datatype's precision won't apply to a vector, and
	[`f32`](https://light.ardi.gg/api/datatypes/numbers/floats/) is always a better choice.

	```luau
	function vect2(--Sync--
		coord: Datatype<number>?
	): Datatype<vector>
	```

	[Learn More](https://light.ardi.gg/api/datatypes/generics/vect2/)
	]=]
	function datatypes.vect2(coord_datatype: Datatype<number>?): Datatype<vector>
		return ERR()
	end

	--[=[
	Represents a Roblox Vector2 userdata. Includes optional `coord` parameter for the datatype each coordinate will use,
	defaulting to an [f32](https://light.ardi.gg/api/datatypes/numbers/floats/). It is worth noting that an
	[`f64`](https://light.ardi.gg/api/datatypes/numbers/floats/) Datatype's precision won't apply to a vector, and
	[`f32`](https://light.ardi.gg/api/datatypes/numbers/floats/) is always a better choice.

	```luau
	function roblox_vect2(--Sync--
		coord: Datatype<number>?
	): Datatype<vector>
	```

	[Learn More](https://light.ardi.gg/api/datatypes/generics/roblox_vect2/)
	]=]
	function datatypes.roblox_vect2(coord_datatype: Datatype<number>?): Datatype<vector>
		return ERR()
	end

	local overloaded_enum
	do
		--[=[
		### Enum types are generally only supported as a first-class feature in the Luau Inference Engine V2.

		An enum represents a set of possible values. Because of limitations with string types, to get full type info from
		some enums you will need to typecast into a string literal type.
		
		```luau
		function enum<Identifier>(--Sync--
			identifiers: { Identifier }
		): Datatype<Identifier>
		```

		[Learn More](http://light.ardi.gg/api/datatypes/generics/enums/#identifier-enums)
		]=]
		local function identifier_overload<Identifier>(identifiers: { Identifier }): Datatype<Identifier>
			return ERR()
		end

		--[=[
		### Enum types are generally only supported as a first-class feature in the Luau Inference Engine V2.
		Some features may work, but type information in older versions of the type inference engine for enums is not officially supported.
		
		### Tagged enums only accept a table as a datatype.
		You must provide a luau table which can be converted into a struct. Anything else will result in an error.

		Passing two parameters to `enum()` represents a tagged enum type. Tagged enums are a set of possible structs, and
		the first parameter is the name for the field which is used to identify each struct.

		```luau
		-- The real type is defined with a type function, the type displayed here is an approximation of tagged enums.
		function enum<IdentifierName, Identifier, PossibleData>(--Sync--
			tag_name: IdentifierName, -- string
			datatypes: { [Identifier]: Datatype<PossibleData> }
		): Datatype<PossibleData & { [IdentifierName]: Identifier }>
		```

		Because of limitations with string types, to get type info from tagged enums you will need to typecast into a
		string literal:
		```luau
		local ty = light.datatypes

		local vfx = ty.enum("kind"::"kind", {
			explosion = {
				position = ty.vect3(),
				magnitude = ty.range(0, 15)
			},
			ability = {
				player: ty.instances.Player
			}
		})
		-- Produces the following type:
		type vfx = {
			kind: "explosion",
			position: vector,
			magnitude: number
		} | {
			kind: "ability",
			player: Player
		}
		```

		[Learn More](http://light.ardi.gg/api/datatypes/generics/enums/#tagged-enums)
		]=]
		local function tagged_overload<Tag, IdentifierMap>(
			tag: Tag,
			identifier_map: IdentifierMap
		): tagged_enum<Tag, IdentifierMap>
			return ERR()
		end

		function overloaded_enum(): any
			return ERR()
		end

		datatypes.enum = overloaded_enum :: typeof(identifier_overload) & typeof(tagged_overload)
	end

	--[=[
	Literals represent a value which is "literally" something. Pass in any value, and it'll be seen as a constant which
	costs zero bytes.
	
	```luau
	function literal<Value>(--Sync--
		value: Value
	): Datatype<Value>
	```

	Literals do not perform any validation on inputs, instead overwriting what gets encoded with the value provided. If
	you want to check the type of the input, you can use an
	[Identifier Enum](http://light.ardi.gg/api/datatypes/generics/enums/#identifier-enums) with only a single item:
	```luau
	local ty = light.datatypes

	local literal = ty.literal(15)
	local checked_literal = ty.enum({15})
	```

	[Learn More](https://light.ardi.gg/api/datatypes/generics/literal/)
	]=]
	function datatypes.literal<Value>(value: Value): Datatype<Value>
		return ERR()
	end

	--[=[
	A whole host of things can go wrong while using computed—so I'll leave you to read
	[the docs](http://light.ardi.gg/api/datatypes/generics/computed/) instead. This function is primarily used for
	networking linkedlists.

	```luau
	function computed<Output>(--Sync--Experimental--
		lambda: () -> (Datatype<Output>)
	): Datatype<Output>
	```
	]=]
	function datatypes.computed<Output>(
		lambda: () -> (Datatype<Output>)
	): Datatype<Output>
		return ERR()
	end

	--[=[
	Represents a buffer in memory. Includes an optional Datatype for length, which defaults
	to [`vlq(3)`](https://light.ardi.gg/api/datatypes/generics/vlq). The length datatype should NOT be a regular
	number—instead: use a datatype that represents a number, like a
	[`uint`](https://light.ardi.gg/api/datatypes/numbers/uints/), or
	[`range`](https://light.ardi.gg/api/datatypes/generics/range/).

	```luau
	function buff(--Sync--
		length: Datatype<number>?
	): Datatype<buffer>
	```

	[Learn More](https://light.ardi.gg/api/datatypes/generics/buff/)
	]=]
	function datatypes.buff(length: Datatype<number>?): Datatype<buffer>
		return ERR()
	end

	--[=[
	Represents `true | false`. Booleans (for most intents and purposes) cost 1/8th of a byte to send over the
	network.

	[Learn More](http://light.ardi.gg/api/datatypes/bool/)
	]=]
	local bool = ... :: Datatype<boolean>
	datatypes.bool = bool

	--[=[
	### Consider using [Instances](http://light.ardi.gg/api/datatypes/instances/) or [Checked](http://light.ardi.gg/api/datatypes/checked/) instead of `any`. `any` can not validate that the type sent over the network is correct, and can be manipulated by exploiters.
	Any is a Datatype that represents a value which should be serialized with the format Roblox's Remote Events use.
	Using this while sending unreliably can cause issues if the packet is too large.

	[Learn More](http://light.ardi.gg/api/datatypes/any/)
	]=]
	local any = ... :: Datatype<any>
	datatypes.any = any

	--[=[
	Light supports validated types for (almost) every Instance.

	Instances are generally an [any](http://light.ardi.gg/api/datatypes/any/) Datatype that check to make sure the value
	being sent is a valid Roblox Instance of a specific classname. Using these datatypes while sending unreliably can
	cause issues if the packet is too large.

	[Learn More](http://light.ardi.gg/api/datatypes/instances/)
	]=]
	local instances = ... :: instance_classes.InstanceClassnameTable
	datatypes.instances = instances

	--[=[
	For types that are especially hard to describe, you can use `checked`. Checked is generally an
	[any](http://light.ardi.gg/api/datatypes/any/) Datatype which allows you to pass a "sanity check" callback. This
	makes sure that even though Roblox's default networking is used, you still get proper type validation & annotation.

	```luau
	function checked<Input, Checked>(
		sanity_check: (Input) -> (Checked)
	): Datatype<Checked>
	```
	
	[Learn More](http://light.ardi.gg/api/datatypes/checked/)
	]=]
	function datatypes.checked<Input, Checked>(
		sanity_check: (Input) -> (Checked)
	): Datatype<Checked>
		return ERR()
	end
end

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
		error(debug.traceback("Invalid Datatype: Datatype does not exist!"))
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
				debug.traceback(
					`Invalid cached datatype: Expected a string key at key "{key}", got type {typeof(key)}`
				)
			)
		end
		output[key] = cached(value)
	end

	return holy_datatypes.struct(output)
end

--[=[
array mirror with datatype caching
]=]
local function arr<Item>(
	item_datatype: HolyDatatype<Item>,
	length_datatype: HolyDatatype<number>?
): HolyDatatype<{ Item }>
	return holy_datatypes.arr(
		cached(item_datatype),
		length_datatype or holy_datatypes.u16
	)
end

--[=[
map mirror with datatype caching
]=]
local function map<Key, Value>(
	key_datatype: HolyDatatype<Key>,
	value_datatype: HolyDatatype<Value>,
	length_datatype: HolyDatatype<number>?
): HolyDatatype<{ [Key]: Value }>
	return holy_datatypes.map(
		cached(key_datatype),
		cached(value_datatype),
		length_datatype or holy_datatypes.u16
	)
end

--[=[
struct mirror with datatype caching
]=]
local function struct<FieldValues>(fields: { [string]: FieldValues }): HolyDatatype<{ [string]: FieldValues }>
	local cached_fields = table.clone(fields) :: { [string]: Datatype<FieldValues> }

	for field_name, field_datatype in fields do
		cached_fields[field_name] = cached(field_datatype)
	end

	return holy_datatypes.struct(cached_fields)
end
datatypes.arr = arr :: any
datatypes.map = map :: any
datatypes.struct = struct :: any

--[=[
1:1 mirror of vlq
]=]
local function vlq(max_bytes: number?): HolyDatatype<number>
	return holy_datatypes.vlq(max_bytes or 7)
end
datatypes.vlq = vlq :: any

--[=[
1:1 mirror of str
]=]
local function str(length: HolyDatatype<number>?)
	return holy_datatypes.str(length or vlq(3))
end
datatypes.str = str :: any

--[=[
1:1 mirror of range
]=]
local function range(minimum: number, maximum: number): HolyDatatype<number>
	return holy_datatypes.range(minimum, maximum)
end
datatypes.range = range :: any

--[=[
vect3 mirror with datatype caching
]=]
local function vect3(coord: HolyDatatype<number>?): HolyDatatype<vector>
	return holy_datatypes.vect3(coord or holy_datatypes.f32)
end
datatypes.vect3 = vect3 :: any

--[=[
vect2 mirror with datatype caching
]=]
local function vect2(coord: HolyDatatype<number>?): HolyDatatype<vector>
	return holy_datatypes.vect2(cached(coord or holy_datatypes.f32))
end
datatypes.vect2 = vect2 :: any

--[=[
1:1 mirror of literal
]=]
local function literal<Value>(value: Value): HolyDatatype<Value>
	return holy_datatypes.literal(value)
end
datatypes.literal = literal :: any

--[=[
1:1 mirror of computed
]=]
local function computed<Output>(lambda: () -> (HolyDatatype<Output>)): HolyDatatype<Output>
	return holy_datatypes.computed(lambda)
end
datatypes.computed = computed :: any

--[=[
1:1 mirror of buff
]=]
local function buff(length: HolyDatatype<number>?): HolyDatatype<buffer>
	return holy_datatypes.buff(length or vlq(3))
end
datatypes.buff = buff :: any

return datatypes
