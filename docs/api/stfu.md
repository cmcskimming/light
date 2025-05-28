# Shut The Fuck Up

This function silences warnings from datatype assembly, as well as strips information from runtime error reporting.

## `#!luau function light.stfu`

```luau title='<!-- client --> <!-- server --> <!-- shared --> <!-- sync -->'
function stfu(
    sybau: boolean
): ()
```

As an example, you may want to send an array of [`any`](./datatypes/any.md). Since `any` is considered "nilable" by
default, using it in an array will print a warning to your console. To silence it, you can use `#!luau light.stfu()`:

```luau
local ty = light.datatypes

light.stfu(true)
local arr_any = ty.arr(ty.any)
light.stfu(false)

return light.container({
    foo = { ty.u8 },
    bar = arr_any,
})
```
