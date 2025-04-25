# Vect2

Represents a 2 component <a href="https://luau.org/typecheck#builtin-types" target="_blank">luau `#!luau vector`</a>.

There is an optional `coord` parameter representing each coordinate (`x`, `y`) which defaults to
[`f32`](../numbers/floats.md). It is worth noting that an [`f64`](../numbers/floats.md) [Datatype](../index.md#what-is-a-datatype)'s
precision won't apply here, so [`f32`](../numbers/floats.md) is always better for vectors.

## `#!luau function light.datatypes.vect2`

```luau title='<!-- client --> <!-- server --> <!-- shared --> <!-- sync -->'
function vect2(
    coord: Datatype<number>?
): Datatype<vector>
```

The `coord` parameter defines how each coordinate of [`#!luau light.vect2()`] will be encoded. If left unselected, it
will choose [`float32`](../numbers/floats.md) by default. Luau cannot represent floats beyond
[`f32`](../numbers/floats.md) in a vector, so using a [`f64`](../numbers/floats.md) for this would be wasteful.
