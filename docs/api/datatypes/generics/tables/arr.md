# Arrays

Arrays are quite simple.

An array represents a contiguous list of values in a table. I.e., `#!luau { "a", "b", "c" }`

An array shouldn't have any `#!luau nil`s or "gaps". If you want holes in a table, use [Maps](./map.md).

You can define a valid array [Datatype](../../index.md#what-is-a-datatype) using a simple table, just like luau:

```luau
local ty = light.datatypes

local some_array = { ty.u8 }
```

Using the above table syntax will behave the same as passing the table into the API shown below.

## `#!luau function light.datatypes.arr`

```luau title='<!-- shared --> <!-- sync -->'
function arr<Item>(
    item: Datatype<Item>,
    length: Datatype<number>?
): (Datatype<{T}>)
```

First argument should be any [Datatype](../../index.md#what-is-a-datatype) which cannot be `#!luau nil`. The `length`
parameter describes the number of items in the array, and will default to
[`#!luau datatypes.u16`](../../numbers/uints.md).

The length datatype should NOT be a regular number—instead: use a
datatype that represents a number, like a [`uint`](../../numbers/uints.md), or a
[`range`](../range.md#function-lightdatatypesrange).

A couple of ways you could use the optional `length` parameter:

```luau
local some_arr = ty.arr( ty.u8, ty.range(0, 50) ) -- Array should have between 0 and 50 items.
```

```luau
local some_arr = ty.arr( ty.u8, ty.literal(3) ) -- Array will always have three items.
```

```luau
local some_arr = ty.arr( ty.u8, ty.u8 ) -- between 0-255 items.
```
