# Floating Points

Floating points represent a number with decimal places.

You can tell a [Datatype](../index.md#what-is-a-datatype) is a floating point number by the preceding `f` prefix. The number afterward
tells you how many bits the [Datatype](../index.md#what-is-a-datatype) costs to send over the network.

| Name   | Size      | Minimum Int    | Maximum Int   |
| -----: | :-------- | -------------- | ------------- |
| `f32`  | `4 bytes` | `−16777216`    | `16777216`    |
| `f64`  | `8 bytes` | `-2^53`        | `2^53`        |

You can access each one with `light.datatypes.<Name>`.
