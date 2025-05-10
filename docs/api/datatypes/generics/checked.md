# Checked

For types that are especially hard to describe, you could use `checked`. Checked is generally an [any](../any.md)
[Datatype](../index.md#what-is-a-datatype) which allows you to pass a "sanity check" callback. This makes sure that even though Roblox's
default networking is used, you still get proper type validation & annotation.

## `#!luau function light.datatypes.checked`

```luau title='<!-- shared --> <!-- sync -->'
function checked<Input, Checked>(
    sanity_check: (Input) -> (Checked)
): (Datatype<Checked>)
```

## Example

Let's say you want to send a [SkateboardPlatform](https://robloxapi.github.io/ref/class/SkateboardPlatform.html)
across the network. <small>(Blasphemy)</small>

```luau title='blasphemy.luau'
local ty = light.datatypes

local skateboard_platform = ty.checked(function(input: Instance)
    assert(input:IsA("SkateboardPlatform"))
    return input :: SkateboardPlatform
end)
```
