# Tables

Table [Datatypes](../../index.md#what-is-a-datatype) represent a luau table.

A big advantage to light as a library is that all [Datatypes](../../index.md#what-is-a-datatype) which directly represent a table can be
defined easily with lua table syntax and used almost anywhere in the library. For more info, see
[`#!luau datatypes.cached()`](../cached.md).

## [Arrays](./arr.md) [`#!luau datatypes.arr()`](./arr.md#function-lightdatatypesarr)

```luau
local ty = light.datatypes
local u8 = ty.u8

local some_array = { u8 } -- This is a totally valid array Datatype
```

## [Maps](./map.md) [`#!luau datatypes.map()`](./map.md#function-lightdatatypesmap)

```luau
local str = ty.str()

local some_map = { [str] = u8 }
-- Exporting types has never been easier
export type some_map = typeof(some_map)
```

## [Structs](./struct.md) [`#!luau datatypes.struct()`](./struct.md#function-lightdatatypesstruct)

```luau
local struct = {--(1)!
    a = u8,
    b = {
        c = { u8 },
        d = { [str] = u8 }
    }
}
```

1. Struct Merging

    Because of this design, merging structs together is as simple as writing yourself a table_merge utility:

    ```luau title='struct_merge.luau'
    local function struct_merge<From, Into>(from: From, into: Into): Into & From
        local output = table.clone(into)
        for field_name, field_type in from do
            assert(not output[field_name], `Duplicate Field Name: {field_name}`)
            output[field_name] = field_type
        end
        return output
    end
    ```
