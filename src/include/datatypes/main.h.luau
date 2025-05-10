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
local datatypes_types = require("./types")
local instance_class_types = require("../instance_classes/types")
local report = require("../../report")

type Datatype<T = any> = datatypes_types.Datatype<T>

local function MISSING_IMPL(): any
	error(report.bug(report.problem("MISSING IMPLEMENTATION")))
end

local datatypes = {
	u8 = ... :: Datatype<number>,
	u16 = ... :: Datatype<number>,
	u24 = ... :: Datatype<number>,
	u32 = ... :: Datatype<number>,
	u40 = ... :: Datatype<number>,
	u48 = ... :: Datatype<number>,
	u53 = ... :: Datatype<number>,

	i8 = ... :: Datatype<number>,
	i16 = ... :: Datatype<number>,
	i24 = ... :: Datatype<number>,
	i32 = ... :: Datatype<number>,
	i40 = ... :: Datatype<number>,
	i48 = ... :: Datatype<number>,
	i54 = ... :: Datatype<number>,

	f32 = ... :: Datatype<number>,
	f64 = ... :: Datatype<number>,
}

--[=[
Instances are generally [Any](http://light.ardi.gg/api/datatypes/any/) [Datatypes](http://light.ardi.gg/api/datatypes/#what-is-a-datatype)
which represent a Roblox Instance Classname. Using these datatypes while sending unreliably can cause consistent
packet dropping issues if the packet is too large.
]=]
datatypes.instances = ... :: instance_class_types.InstanceClassnameTable

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
	return MISSING_IMPL()
end

--[=[
An array represents a contiguous list of values in a table. I.e., `{ "a", "b", "c" }`

Arrays take in a datatype for what kind of item they should use, and an optional parameter for length which defaults
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
	return MISSING_IMPL()
end

--[=[
A map represents a set of keys mapping to values in a table. I.e., `{ ["random string"] = 1234 }`

Maps take in a datatype for their key, a datatype for their value, and an optional parameter for length which
defaults to [`u16`](https://light.ardi.gg/api/datatypes/numbers/uints/). The length datatype should NOT be a regular
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
	return MISSING_IMPL()
end

--[=[
A struct represents a fixed set of string keys and value datatypes.

Structs are not guaranteed to have exactly the field order you defined them with, but the order of their fields is
identical on client and server.

```luau
function struct<Fields>(--Sync--
	map: Fields -- { [string]: Datatype }
): Datatype<Fields>
```

[Learn More](https://light.ardi.gg/api/datatypes/generics/tables/struct/)
]=]
function datatypes.struct<Fields>(map: Fields): Datatype<Fields>
	return MISSING_IMPL()
end

--[=[
Variable Length Quantities represent arbitrarily sized unsigned integers. A VLQ takes less space for generally
"smaller" numbers, so it can allow you to save on space if you don't know the size of a number ahead of time. There
is an optional `max_bytes` parameter to limit the number of bytes it can occupy, defaulting to 7.

```luau
function vlq(--Sync--
	max_bytes: number?
): Datatype<number>
```
]=]
function datatypes.vlq(max_bytes: number?): Datatype<number>
	return MISSING_IMPL()
end

--[=[
Optionals represent a value which could be `nil`, and can be applied to any datatype. Optionals are most often used
within a [`struct`](http://light.ardi.gg/api/datatypes/generics/tables/struct/), where you might not want or need all
fields to exist in the data you're sending. A fair alternative to an optional Datatype can be a
[`Tagged Enum`](https://light.ardi.gg/api/datatypes/generics/enums/#tagged-enums)

```luau
function optional<Inner>(--Sync--
	inner: Datatype<Inner>
): Datatype<Inner?>
```

[Learn More](https://light.ardi.gg/api/datatypes/generics/optional/)
]=]
function datatypes.optional<Inner>(inner_datatype: Datatype<Inner>): Datatype<Inner?>
	return MISSING_IMPL()
end

--[=[
Represents a string value. Includes an optional parameter for length which defaults to
[`vlq(3)`](https://light.ardi.gg/api/datatypes/generics/vlq). The length datatype should NOT be a regular
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
	return MISSING_IMPL()
end

--[=[
Represents a range of possible [`uints`](https://light.ardi.gg/api/datatypes/numbers/uints) by providing a minimum
and maximum value.

If you serialize a number which is larger or smaller than the range, this datatype will cause an error. To clamp the
number instead, use [clamp](https://light.ardi.gg/api/datatypes/generics/clamp/)

```luau
function range(--Sync--
	minimum: number,
	maximum: number
): Datatype<number>
```

[Learn More](https://light.ardi.gg/api/datatypes/generics/range/)
]=]
function datatypes.range(minimum: number, maximum: number): Datatype<number>
	return MISSING_IMPL()
end

--[=[
Represents a range of possible [`uints`](https://light.ardi.gg/api/datatypes/numbers/uints) by providing a minimum
and maximum value.

If you serialize a number which is larger or smaller than the range, this datatype will clamp the input to the minimum
and maximum. If you instead want this to error, you can use [range](https://light.ardi.gg/api/datatypes/generics/range/)

```luau
function clamp(--Sync--
	minimum: number,
	maximum: number
): Datatype<number>
```

[Learn More](https://light.ardi.gg/api/datatypes/generics/clamp/)
]=]
function datatypes.clamp(minimum: number, maximum: number): Datatype<number>
	return MISSING_IMPL()
end

--[=[
Represents a 3 component luau vector.

There is an optional `coord` parameter representing each coordinate (`x`, `y`, `z`) which defaults to
[`f32`](https://light.ardi.gg/api/datatypes/numbers/floats/). It is worth noting that an
[`f64`](https://light.ardi.gg/api/datatypes/numbers/floats/) Datatype's precision won't apply here, so
[`f32`](https://light.ardi.gg/api/datatypes/numbers/floats/) is always better for vectors.

```luau
function vect3(--Sync--
	coord: Datatype<number>?
): Datatype<vector>
```

[Learn More](https://light.ardi.gg/api/datatypes/generics/vect3/)
]=]
function datatypes.vect3(coord_datatype: Datatype<number>?): Datatype<vector>
	return MISSING_IMPL()
end

--[=[
Represents a 2 component luau vector.

There is an optional `coord` parameter representing each coordinate (`x`, `y`) which defaults to
[`f32`](https://light.ardi.gg/api/datatypes/numbers/floats/). It is worth noting that an
[`f64`](https://light.ardi.gg/api/datatypes/numbers/floats/) Datatype's precision won't apply here, so
[`f32`](https://light.ardi.gg/api/datatypes/numbers/floats/) is always better for vectors.

```luau
function vect2(--Sync--
	coord: Datatype<number>?
): Datatype<vector>
```

[Learn More](https://light.ardi.gg/api/datatypes/generics/vect2/)
]=]
function datatypes.vect2(coord_datatype: Datatype<number>?): Datatype<vector>
	return MISSING_IMPL()
end

--[=[
Represents a Roblox Vector2 userdata.

There is an optional `coord` parameter representing each coordinate (`x`, `y`) which defaults to
[`f32`](https://light.ardi.gg/api/datatypes/numbers/floats/). It is worth noting that an
[`f64`](https://light.ardi.gg/api/datatypes/numbers/floats/) Datatype's precision won't apply here, so
[`f32`](https://light.ardi.gg/api/datatypes/numbers/floats/) is always better for vectors.

```luau
function roblox_vect2(--Sync--
	coord: Datatype<number>?
): Datatype<vector>
```

[Learn More](https://light.ardi.gg/api/datatypes/generics/roblox_vect2/)
]=]
function datatypes.roblox_vect2(coord_datatype: Datatype<number>?): Datatype<vector>
	return MISSING_IMPL()
end

--[=[
Represents a Roblox CFrame userdata.

There is an optional `position` parameter representing each positional coordinate (`x`, `y`, `z`) which defaults to
[f32](https://light.ardi.gg/api/datatypes/numbers/floats/). The orientation occupies a fixed four bytes.

```luau
function cframe(--Sync--
	position: Datatype<number>?
): Datatype<CFrame>
```

[Learn More](https://light.ardi.gg/api/datatypes/generics/cframe/)
]=]
function datatypes.cframe(position_datatype: Datatype<number>?): Datatype<CFrame>
	return MISSING_IMPL()
end

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
local function enum_identifier_overload<Identifier>(identifiers: { Identifier }): Datatype<Identifier>
	return MISSING_IMPL()
end

--[=[
### Enum types are generally only supported as a first-class feature in the Luau Inference Engine V2.
Some features may work, but type information in older versions of the type inference engine for enums is not
officially supported.

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
local function enum_tagged_overload<Tag, IdentifierMap>(
	tag: Tag,
	identifier_map: IdentifierMap
): datatypes_types.tagged_enum<
	Tag,
	IdentifierMap
>
	return MISSING_IMPL()
end

datatypes.enum = ... :: typeof(enum_identifier_overload) & typeof(enum_tagged_overload)

--[=[
Literals represent a value which is "literally" something. Any value you pass to a literal will become a constant and
cost zero bytes.

```luau
function literal<Value>(--Sync--
	value: Value
): Datatype<Value>
```

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
A whole host of things can go wrong while using computed—so I'll leave you to read
[the docs](http://light.ardi.gg/api/datatypes/generics/computed/) instead. This function is primarily used for
networking linkedlists.

```luau
function computed<Output>(--Sync--Experimental--
	lambda: () -> (Datatype<Output>)
): Datatype<Output>
```
]=]
function datatypes.computed<Output>(lambda: () -> Datatype<Output>): Datatype<Output>
	return MISSING_IMPL()
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
	return MISSING_IMPL()
end

--[=[
For types that are especially hard to describe, you could use `checked`. Checked is generally an
[any](http://light.ardi.gg/api/datatypes/any/) Datatype which allows you to pass a "sanity check" callback. This
makes sure that even though Roblox's default networking is used, you still get proper type validation & annotation.

```luau
function checked<Input, Checked>(
	sanity_check: (Input) -> (Checked)
): Datatype<Checked>
```

[Learn More](http://light.ardi.gg/api/datatypes/checked/)
]=]
function datatypes.checked<Input, Checked>(sanity_check: (Input) -> Checked): Datatype<Checked>
	return MISSING_IMPL()
end

--[=[
Represents `true | false`. Booleans (for most intents and purposes) cost 1/8th of a byte to send over the
network.

[Learn More](http://light.ardi.gg/api/datatypes/bool/)
]=]
datatypes.bool = ... :: Datatype<boolean>

--[=[
### Consider using [Instances](http://light.ardi.gg/api/datatypes/instances/) or [Checked](http://light.ardi.gg/api/datatypes/checked/) instead of `any`. `any` can not validate that the type sent over the network is correct, and can be manipulated by exploiters.
Any is a Datatype that represents a value which should be serialized with the format Roblox's Remote Events use.
Using this while sending unreliably can cause issues if the packet is too large.

[Learn More](http://light.ardi.gg/api/datatypes/any/)
]=]
datatypes.any = ... :: Datatype<any>

-- Prevent datatypes from inferring a metatable
setmetatable(datatypes :: any, {
	-- Prevent Datatypes from being indexed if implementation isn't there
	__index = function(_, index_name: any): ()
		error(
			report.bug(
				report.problem(`Error while indexing: key of name "{index_name}" is undefined!`)
			)
		)
	end,
})

return datatypes
