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
do
end
type RECUR_ID = "\127\r\127"

local IMPL: any = nil

local datatypes_types = require("./types")
local header_graph = require("../graph")
local instance_class_types = require("../instance_classes/types")

type Datatype<T = any> = datatypes_types.Datatype<T>

local function MISSING_IMPL(): any
	error("unreachable")
end

local datatypes = {
	--[=[
	An unsigned integer representing any positive value up to 255. occupies 1 byte.
	]=]
	u8 = IMPL :: Datatype<number>,
	--[=[
	An unsigned integer representing any positive value up to 65,535. occupies 2 bytes.
	]=]
	u16 = IMPL :: Datatype<number>,
	--[=[
	An unsigned integer representing any positive value up to 16,777,215. occupies 3 bytes.
	]=]
	u24 = IMPL :: Datatype<number>,
	--[=[
	An unsigned integer representing any positive value up to 4,294,967,295. occupies 4 bytes.
	]=]
	u32 = IMPL :: Datatype<number>,
	--[=[
	An unsigned integer representing any positive value up to 2^40 - 1. occupies 5 bytes.
	]=]
	u40 = IMPL :: Datatype<number>,
	--[=[
	An unsigned integer representing any positive value up to 2^48 - 1. occupies 6 bytes.
	]=]
	u48 = IMPL :: Datatype<number>,
	--[=[
	An unsigned integer representing any positive value up to 2^53. occupies 7 bytes.
	]=]
	u56 = IMPL :: Datatype<number>,

	--[=[
	Represents any value between 127 and -128. occupies 1 byte.
	]=]
	i8 = IMPL :: Datatype<number>,
	--[=[
	Represents any value between 32,767 and -32,768. occupies 2 bytes.
	]=]
	i16 = IMPL :: Datatype<number>,
	--[=[
	Represents any value between 8,388,607 and -8,388,608. occupies 3 bytes.
	]=]
	i24 = IMPL :: Datatype<number>,
	--[=[
	Represents any value between 2,147,483,647 and -2,147,483,647. occupies 4 bytes.
	]=]
	i32 = IMPL :: Datatype<number>,
	--[=[
	Represents any value between 2^39 - 1 and - 2^39. occupies 5 bytes.
	]=]
	i40 = IMPL :: Datatype<number>,
	--[=[
	Represents any value between 2^47 - 1 and - 2^47. occupies 6 bytes.
	]=]
	i48 = IMPL :: Datatype<number>,
	--[=[
	Represents any value between 2^52 - 1 and - 2^52. occupies 7 bytes.
	]=]
	i53 = IMPL :: Datatype<number>,

	--[=[
	Represents a number with decimal places. Can accurately represent any integer between 16,777,216 and -16,777,216.
	Numbers beyond that begin to lose accuracy.
	]=]
	f32 = IMPL :: Datatype<number>,

	--[=[
	Represents a number with decimal places. This represents any number that a luau `number` can.
	]=]
	f64 = IMPL :: Datatype<number>,

	--[=[
	```luau
	local bool: Datatype<true | false>
	```

	Represents `true` | `false`.

	[Learn More](http://light.ardi.gg/api/datatypes/bool/)
	]=]
	bool = IMPL :: Datatype<boolean>,

	--[=[
	```luau
	local any: Datatype<any>
	```

	### Consider using [Instances](http://light.ardi.gg/api/datatypes/instances/) or [Checked](http://light.ardi.gg/api/datatypes/checked/) instead of `any`. `any` can not validate that the type sent over the network is correct, and can be manipulated by exploiters.
	Any is a Datatype that represents a value which should be serialized with the format Roblox's Remote Events use.
	Using this while sending unreliably can cause issues if the packet is too large.

	[Learn More](http://light.ardi.gg/api/datatypes/any/)
	]=]
	any = IMPL :: Datatype<any>,

	--[=[
	Instances are generally [Any](http://light.ardi.gg/api/datatypes/any/) [Datatypes](http://light.ardi.gg/api/datatypes/#what-is-a-datatype)
	which represent a Roblox Instance Classname. Using these datatypes while sending unreliably can cause consistent
	packet dropping issues if the packet is too large.

	[Learn More](http://light.ardi.gg/api/datatypes/instances/)
	]=]
	instances = IMPL :: instance_class_types.InstanceClassnameTable,
}

--[=[
```luau
function cached<T>(--Sync--
	value: Datatype<T>
): Datatype<T>
```

In light, you can use luau
[`arrays`](https://light.ardi.gg/api/datatypes/generics/tables/arr/),
[`maps`](https://light.ardi.gg/api/datatypes/generics/tables/map/),
and [`structs`](https://light.ardi.gg/api/datatypes/generics/tables/struct/) to define a message Datatype.

This API exists to recursively cache the result of a Datatype. This will internally turn it into a numeric ID if it
isn't one already, rendering it unusable for anything other than ser/des and messages. Messages cache their Datatypes
automatically, but this can be useful in conjunction with other features like
[Computed Datatypes](https://light.ardi.gg/api/datatypes/generics/computed/).

[Learn More](https://light.ardi.gg/api/datatypes/generics/cached/)
]=]
function datatypes.cached<Input>(schema: Input): Datatype<Input>
	return MISSING_IMPL()
end

--[=[
```luau
function arr<Item>(--Sync--
	item: Datatype<Item>,
	length: Datatype<number>?
): Datatype<{ Item }>
```

An array represents a contiguous list of values in a table. E.g., `{ "a", "b", "c" }`

Arrays take in a datatype for what kind of item they should use, and an optional parameter for length which defaults
to [`u16`](https://light.ardi.gg/api/datatypes/numbers/uints/). The length datatype should NOT be a regular
number—instead: use a datatype that represents a number, like a
[`uint`](https://light.ardi.gg/api/datatypes/numbers/uints/), or
[`range`](https://light.ardi.gg/api/datatypes/generics/range/).

[Learn More](https://light.ardi.gg/api/datatypes/generics/tables/arr/)
]=]
function datatypes.arr<Item>(
	item_datatype: Datatype<Item>,
	length_datatype: Datatype<number>?
): Datatype<{ Item }>
	return MISSING_IMPL()
end

--[=[
```luau
function map<Key, Value>(--Sync--
	key: Datatype<Key>,
	value: Datatype<Value>,
	length: Datatype<number>?
): Datatype<{ [Key]: Value }>
```

A map represents a set of keys mapping to values in a table. E.g., `{ ["random string"] = 1234 }`

Maps take in a datatype for their key, a datatype for their value, and an optional parameter for length which
defaults to [`u16`](https://light.ardi.gg/api/datatypes/numbers/uints/). The length datatype should NOT be a regular
number—instead: use a datatype that represents a number, like a
[`uint`](https://light.ardi.gg/api/datatypes/numbers/uints/), or
[`range`](https://light.ardi.gg/api/datatypes/generics/range/).

[Learn More](https://light.ardi.gg/api/datatypes/generics/tables/map/)
]=]
function datatypes.map<Key, Value>(
	key_datatype: Datatype<Key>,
	value_datatye: Datatype<Value>,
	length_datatype: Datatype<number>?
): Datatype<{ [Key]: Value }>
	return MISSING_IMPL()
end

--[=[
```luau
function struct<Fields>(--Sync--
	map: Fields -- { [string]: Datatype }
): Datatype<Fields>
```

A struct represents a fixed set of string keys and value datatypes.

Structs are not guaranteed to have exactly the field order you defined them with, but the order of their fields is
identical on client and server.

[Learn More](https://light.ardi.gg/api/datatypes/generics/tables/struct/)
]=]
function datatypes.struct<Fields>(map: Fields): Datatype<Fields>
	return MISSING_IMPL()
end

--[=[
```luau
function vlq(--Sync--
	max_bytes: number?
): Datatype<number>
```

Variable Length Quantities represent arbitrarily sized unsigned integers. A VLQ takes less space for generally
"smaller" numbers, so it can allow you to save on space if you don't know the size of a number ahead of time. There
is an optional `max_bytes` parameter to limit the number of bytes it can occupy, defaulting to 7.
]=]
function datatypes.vlq(max_bytes: number?): Datatype<number>
	return MISSING_IMPL()
end

--[=[
```luau
function optional<Inner>(--Sync--
	inner: Datatype<Inner>
): Datatype<Inner?>
```

Optionals represent a value which could be `nil`, and can be applied to any datatype. Optionals are most often used
within a [`struct`](http://light.ardi.gg/api/datatypes/generics/tables/struct/), where you might not want or need all
fields to exist in the data you're sending. A fair alternative to an optional Datatype can be a
[`Tagged Enum`](https://light.ardi.gg/api/datatypes/generics/enums/#tagged-enums)

[Learn More](https://light.ardi.gg/api/datatypes/generics/optional/)
]=]
function datatypes.optional<Inner>(inner_datatype: Datatype<Inner>): Datatype<Inner?>
	return MISSING_IMPL()
end

--[=[
```luau
function str(--Sync--
	length: Datatype<number>?
): Datatype<string>
```

Represents a string value. Includes an optional parameter for length which defaults to
[`vlq(3)`](https://light.ardi.gg/api/datatypes/generics/vlq). The length datatype should NOT be a regular
number—instead: use a datatype that represents a number, like a
[`uint`](https://light.ardi.gg/api/datatypes/numbers/uints/), or
[`range`](https://light.ardi.gg/api/datatypes/generics/range/).

[Learn More](https://light.ardi.gg/api/datatypes/generics/str/)
]=]
function datatypes.str(length_datatype: Datatype<number>?): Datatype<string>
	return MISSING_IMPL()
end

--[=[
```luau
function range(--Sync--
	minimum: number,
	maximum: number
): Datatype<number>
```

Represents a range of possible [`uints`](https://light.ardi.gg/api/datatypes/numbers/uints) by providing a minimum
and maximum value.

If you serialize a number which is larger or smaller than the range, this datatype will cause an error. To clamp the
number instead, use [clamp](https://light.ardi.gg/api/datatypes/generics/clamp/)

[Learn More](https://light.ardi.gg/api/datatypes/generics/range/)
]=]
function datatypes.range(minimum: number, maximum: number): Datatype<number>
	return MISSING_IMPL()
end

--[=[
```luau
function clamp(--Sync--
	minimum: number,
	maximum: number
): Datatype<number>
```

Represents a range of possible [`uints`](https://light.ardi.gg/api/datatypes/numbers/uints) by providing a minimum
and maximum value.

If you serialize a number which is larger or smaller than the range, this datatype will clamp the input to the minimum
and maximum. If you instead want this to error, you can use [range](https://light.ardi.gg/api/datatypes/generics/range/)

[Learn More](https://light.ardi.gg/api/datatypes/generics/clamp/)
]=]
function datatypes.clamp(minimum: number, maximum: number): Datatype<number>
	return MISSING_IMPL()
end

--[=[
```luau
function vect3(--Sync--
	coord: Datatype<number>?
): Datatype<vector>
```

Represents a 3 component luau vector.

There is an optional `coord` parameter representing each coordinate (`x`, `y`, `z`) which defaults to
[`f32`](https://light.ardi.gg/api/datatypes/numbers/floats/). It is worth noting that an
[`f64`](https://light.ardi.gg/api/datatypes/numbers/floats/) Datatype's precision won't apply here, so
[`f32`](https://light.ardi.gg/api/datatypes/numbers/floats/) is always better for vectors.

[Learn More](https://light.ardi.gg/api/datatypes/generics/vect3/)
]=]
function datatypes.vect3(coord_datatype: Datatype<number>?): Datatype<vector>
	return MISSING_IMPL()
end

--[=[
```luau
function vect2(--Sync--
	coord: Datatype<number>?
): Datatype<vector>
```

Represents a 2 component luau vector.

There is an optional `coord` parameter representing each coordinate (`x`, `y`) which defaults to
[`f32`](https://light.ardi.gg/api/datatypes/numbers/floats/). It is worth noting that an
[`f64`](https://light.ardi.gg/api/datatypes/numbers/floats/) Datatype's precision won't apply here, so
[`f32`](https://light.ardi.gg/api/datatypes/numbers/floats/) is always better for vectors.

[Learn More](https://light.ardi.gg/api/datatypes/generics/vect2/)
]=]
function datatypes.vect2(coord_datatype: Datatype<number>?): Datatype<vector>
	return MISSING_IMPL()
end

--[=[
```luau
function roblox_vect2(--Sync--
	coord: Datatype<number>?
): Datatype<vector>
```

Represents a Roblox Vector2 class.

There is an optional `coord` parameter representing each coordinate (`x`, `y`) which defaults to
[`f32`](https://light.ardi.gg/api/datatypes/numbers/floats/). It is worth noting that an
[`f64`](https://light.ardi.gg/api/datatypes/numbers/floats/) Datatype's precision won't apply here, so
[`f32`](https://light.ardi.gg/api/datatypes/numbers/floats/) is always better for vectors.

[Learn More](https://light.ardi.gg/api/datatypes/generics/roblox_vect2/)
]=]
function datatypes.roblox_vect2(coord_datatype: Datatype<number>?): Datatype<vector>
	return MISSING_IMPL()
end

--[=[
```luau
function cframe(--Sync--
	position: Datatype<number>?
): Datatype<CFrame>
```

Represents a Roblox CFrame class.

There is an optional `position` parameter representing each positional coordinate (`x`, `y`, `z`) which defaults to
[f32](https://light.ardi.gg/api/datatypes/numbers/floats/). The orientation occupies a fixed four bytes.

[Learn More](https://light.ardi.gg/api/datatypes/generics/cframe/)
]=]
function datatypes.cframe(position_datatype: Datatype<number>?): Datatype<CFrame>
	return MISSING_IMPL()
end

--[=[
### Enum types are generally only supported as a first-class feature in the Luau Inference Engine V2.
Some features may work, but type information in older versions of the type inference engine for enums is not
officially supported.

```luau
function enum<Identifier>(--Sync--
	identifiers: { Identifier }
): Datatype<Identifier>
```

An enum represents a set of possible values. Because of limitations with string types, to get full type info from
some enums you will need to typecast into a string literal type.

[Learn More](http://light.ardi.gg/api/datatypes/generics/enums/#identifier-enums)
]=]
local function enum_identifier_overload<Identifier>(identifiers: { Identifier }): Datatype<Identifier>
	return MISSING_IMPL()
end

--[=[
### Enum types are generally only supported as a first-class feature in the Luau Inference Engine V2.

```luau
-- The real type is defined with a type function, the type displayed here is an approximation of tagged enums.
function enum<IdentifierName, Identifier, PossibleData>(--Sync--
	tag_name: IdentifierName, -- string
	datatypes: { [Identifier]: Datatype<PossibleData> }
): Datatype<PossibleData & { [IdentifierName]: Identifier }>
```

### Tagged enums only accept a table as a datatype.
You must provide a luau table which can be converted into a struct. Anything else will result in an error.

Passing two parameters to `enum()` represents a tagged enum type. Tagged enums are a set of possible structs, and
the first parameter is the name for the field which is used to identify each struct.

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
local function enum_tagged_overload<Tag, IdentifierMap>(
	tag: Tag,
	identifier_map: IdentifierMap
): datatypes_types.tagged_enum<
	Tag,
	IdentifierMap
>
	return MISSING_IMPL()
end

datatypes.enum = IMPL :: typeof(enum_identifier_overload) & typeof(enum_tagged_overload)

--[=[
```luau
function literal<Value>(--Sync--
	value: Value
): Datatype<Value>
```

Literals represent a value which is "literally" something. Any value you pass to a literal will become a constant and
cost zero bytes.

Literals do not perform any validation on inputs, instead overwriting what gets encoded with the value provided. If
you want to check the type of the input, you could use an
[Identifier Enum](http://light.ardi.gg/api/datatypes/generics/enums/#identifier-enums) with only a single item:
```luau
local ty = light.datatypes

local literal = ty.literal(15)
local checked_literal = ty.enum({15})
```

[Learn More](https://light.ardi.gg/api/datatypes/generics/literal/)
]=]
function datatypes.literal<Value>(value: Value): Datatype<Value>
	return MISSING_IMPL()
end

--[=[
```luau
function buff(--Sync--
	length: Datatype<number>?
): Datatype<buffer>
```

Represents a buffer in memory. Includes an optional Datatype for length, which defaults
to [`vlq(3)`](https://light.ardi.gg/api/datatypes/generics/vlq). The length datatype should NOT be a regular
number—instead: use a datatype that represents a number, like a
[`uint`](https://light.ardi.gg/api/datatypes/numbers/uints/), or
[`range`](https://light.ardi.gg/api/datatypes/generics/range/).

[Learn More](https://light.ardi.gg/api/datatypes/generics/buff/)
]=]
function datatypes.buff(length: Datatype<number>?): Datatype<buffer>
	return MISSING_IMPL()
end

--[=[
```luau
function checked<Input, Checked>(
	sanity_check: (Input) -> (Checked)
): Datatype<Checked>
```

For types that are especially hard to describe, you could use `checked`. Checked is generally an
[any](http://light.ardi.gg/api/datatypes/any/) Datatype which allows you to pass a "sanity check" callback. This
makes sure that even though Roblox's default networking is used, you still get proper type validation & annotation.

[Learn More](http://light.ardi.gg/api/datatypes/checked/)
]=]
function datatypes.checked<Input, Checked>(sanity_check: (Input) -> Checked): Datatype<Checked>
	return MISSING_IMPL()
end

return header_graph:define(datatypes)
