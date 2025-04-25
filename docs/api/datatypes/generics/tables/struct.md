# Structs

Structs are quite simple.

A struct represents a fixed set of string keys and value datatypes.

Structs are not guaranteed to have exactly the field order you defined them with, but the order of their fields is
identical on client and server.

You can define a valid struct [Datatype](../../index.md#what-is-a-datatype) using a simple table, just like luau:

```luau
local ty = light.datatypes

local some_struct = {--(1)!
    a = ty.u8,
    b = ty.i16,
    c = {
        some = ty.str(),
        thing = ty.u8
    }
}
```

1. Struct Merging

    Because of this design, merging structs together is as simple as writing a table merging utility:

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

Using the above table syntax will behave the same as passing the table into the API shown below.

## `#!luau function light.datatypes.struct`

```luau title='<!-- client --> <!-- server --> <!-- shared --> <!-- sync -->'
function struct<Fields>(--Sync--
    map: Fields -- { [string]: Datatype }
): Datatype<Fields>
```
