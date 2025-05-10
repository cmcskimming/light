# Message

Message does the same thing as a [`#!luau light.container()`](./container.md), but doesn't force you to put it in a
string map.

## `#!luau function light.message` <small>(On The Client)</small>

```luau title='<!-- shared --> <!-- sync --> <!-- async -->'
function message<Data>(
    name: string,
    template: Datatype<Data>
): (Message<Data>)
```

## `#!luau function light.message` <small>(On The Server)</small>

```luau title='<!-- shared --> <!-- sync -->'
function message<Data>(
    name: string,
    template: Datatype<Data>
): (Message<Data>)
```

`template` in both above samples should always be any valid [Datatype](../../../datatypes/index.md#what-is-a-datatype).
This includes [Datatypes](../../../datatypes/index.md#what-is-a-datatype) like arrays or maps that are defined with luau tables.
I.e., `#!luau { light.datatypes.u8 }`

If you wanted to create messages en-masse without restricting yourself to the structure of a container, this can be
very useful. You could also use it to re-invent the wheel:

```luau
local ty = light.datatypes

return light.container({
    abc = { ty.u8 }, -- send a table of u8 numbers
})
```

Is equivalent* to:

```luau
return {
    abc = light.message("abc", { light.u8 })
}
```
