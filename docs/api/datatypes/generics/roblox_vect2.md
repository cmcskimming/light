# Vector2

Represents a
<a href="https://create.roblox.com/docs/reference/engine/datatypes/Vector2" target="_blank">Roblox `#!luau Vector2`</a>
[Datatype](../index.md#what-is-a-datatype).

There is an optional `coord` parameter representing each coordinate (`x`, `y`) which defaults to
[`f32`](../numbers/floats.md). It is worth noting that an [`f64`](../numbers/floats.md) [Datatype](../index.md#what-is-a-datatype)'s
precision won't apply here, so [`f32`](../numbers/floats.md) is always better for vectors.

## `#!luau function light.datatypes.roblox_vect2`

```luau title='<!-- shared --> <!-- sync -->'
function roblox_vect2(
    coord: Datatype<number>?
): Datatype<vector>
```
