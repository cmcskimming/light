# Floating Points

Floating points represent a number with decimal places.

You can tell a [Datatype](../index.md#what-is-a-datatype) represents a decimal number if its name has the `f` prefix.
The number afterward tells you how many bits the [Datatype](../index.md#what-is-a-datatype) uses to represent values
sent over the network.

## Size Index

| Name   | Size      | Maximum Int                                       | Minimum Int                                           |
| -----: | :-------- | ------------------------------------------------- | ----------------------------------------------------- |
| `f32`  | `4 bytes` | `2^24`<small>(16,777,216)</small>                 | `-(2^24)`<small>(−16,777,216)</small>                 |
| `f64`  | `8 bytes` | `2^53`<small>(9,007,199,254,740,992)</small>      | `-(2^53)`<small>(-9,007,199,254,740,992)</small>      |

You can access each one with `light.datatypes.<Name>`.
