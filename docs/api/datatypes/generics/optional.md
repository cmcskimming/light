# Optionals

Optionals represent a value which could be `nil`, and can be applied to any datatype. Optionals are most often used from
within a [`struct`](./tables/struct.md), where you might not want or need all fields to exist in the data you're
sending.

## `#!luau function light.datatypes.optional`

```luau title='<!-- client --> <!-- server --> <!-- shared --> <!-- sync -->'
function optional<Inner>(
    inner: Datatype<Inner>
): Datatype<Inner?>
```

## Example

Let's say you want to represent some settings that have a value or be unset. A really simple and efficient way to encode
that data is with a struct of optionals.

```luau
local ty = light.datatypes

local opt = ty.optional

local settings_packet = {
    field_of_view = opt(ty.range(60, 140)),
    depth_of_field = opt(ty.bool),
    sprint_key = opt(ty.)
}
```
