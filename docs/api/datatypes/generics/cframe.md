# CFrame

Represents a
<a href="https://create.roblox.com/docs/reference/engine/datatypes/CFrame" target="_blank">Roblox `#!luau CFrame`</a>
[Datatype](../index.md#what-is-a-datatype).

There is an optional `coord` parameter representing each coordinate (`x`, `y`, `z`) which defaults to
[`f32`](../numbers/floats.md). A CFrame's Orientation requires exactly six[¹](#technical-details) bytes to represent.

## `#!luau function light.datatypes.cframe`

```luau title='<!-- client --> <!-- server --> <!-- shared --> <!-- sync -->'
function cframe(
    coord: Datatype<number>?
): Datatype<vector>
```

## Technical Details

CFrame orientation is encoded with Axis-Angles representation. The accuracy of each component varies depending on the X
axis.

[//]: # ( X accurate to ± 2 / (2^16) )
[//]: # ( Y accurate to ± ( 2 * (1 - X ^ 2) ^ 0.5 ) / 2 ^ 15 )
[//]: # ( Z accurate to ± X_accuracy + Y_accuracy )

### Axis Accuracy

| Inputs     | ± `X` Axis    | ± `Y` Axis    | ± <= `Z` Axis  |
| ---------- | ------------- | ------------- | ------------- |
| X = `0.00` | `0.000030518` | `0.000061035` | `0.000091553` |
| X = `0.10` | `0.000030518` | `0.000060729` | `0.000091247` |
| X = `0.20` | `0.000030518` | `0.000059802` | `0.000090320` |
| X = `0.30` | `0.000030518` | `0.000058224` | `0.000088741` |
| X = `0.40` | `0.000030518` | `0.000055940` | `0.000086457` |
| X = `0.50` | `0.000030518` | `0.000052857` | `0.000083376` |
| X = `0.60` | `0.000030518` | `0.000048828` | `0.000079346` |
| X = `0.70` | `0.000030518` | `0.000043587` | `0.000074105` |
| X = `0.80` | `0.000030518` | `0.000036621` | `0.000067139` |
| X = `0.90` | `0.000030518` | `0.000026604` | `0.000057122` |
| X = `1`    | `0.000030518` | `0.000000000` | `0.000030518` |

### Angles Accuracy

The "Angles" portion of Axis-Angles has an error flooring to the nearest `0.00549324788°`

## (Even More) Technical Details

The `Z` axis error is less than or equal to the sum of the `X` and `Y` error.
You can get the `Y` axis error with the following formula:
<br>`( 2 · (1 - X ^ 2) ^ 0.5 ) / 2 ^ 15`
<br>Want to know why? See [The Internals Blog](../../../blog/internals/cframe_encoding.md)
