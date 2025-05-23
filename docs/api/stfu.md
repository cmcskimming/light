# Shut The Fuck Up

This function silences warnings from schema assembly, as well as makes runtime errors less susceptible to DOS attacks.

## `#!luau function light.stfu`

```luau title='<!-- client --> <!-- server --> <!-- shared --> <!-- sync -->'
function stfu(
    sybau: boolean?
): ()
```

As an example, you may want to send an array of instances which may not be replicated yet over the network. Normally,
creating an array datatype with an optional value prints a warning to the console. To silence it, you can use
`#!luau light.stfu()`:

```luau
local ty = light.datatypes
local instance = ty.instances.instance

light.stfu()
local arr_instances = ty.arr(ty.optional(instance))
-- tell light to exit sybau mode
light.stfu(false)

return light.container({
    foo = { ty.u8 },
    bar = arr_instances,
})
```
