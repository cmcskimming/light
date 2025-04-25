# Vect3

Represents a 3 component <a href="https://luau.org/typecheck#builtin-types" target="_blank">luau `#!luau vector`</a>.

There is an optional `coord` parameter representing each coordinate (`x`, `y`, `z`) which defaults to
[`f32`](../numbers/floats.md). It is worth noting that an [`f64`](../numbers/floats.md) [Datatype](../index.md#what-is-a-datatype)'s
precision won't apply here, so [`f32`](../numbers/floats.md) is always be better for vectors.

## `#!luau function light.datatypes.vect3`

```luau title='<!-- client --> <!-- server --> <!-- shared --> <!-- sync -->'
function vect3(
    coord: Datatype<number>?
): Datatype<vector>
```
