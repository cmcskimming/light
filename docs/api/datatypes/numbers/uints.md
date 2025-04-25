# Unsigned Integers

Unsigned Integers represent a whole number which is greater than or equal to zero. For numbers with decimal places, you
should use a [Float](./floats.md).

You can tell a datatype is an unsigned number by the preceding `u` prefix. The number afterward tells you how many bits
the [Datatype](../index.md#what-is-a-datatype) costs to send over the network.

| Name   | Size        | Minimum Int    | Maximum Int     |
| -----: | :---------- | -------------- | --------------- |
| `u8`   | `1 byte`    | `0`            | `255`           |
| `u16`  | `2 bytes`   | `0`            | `65,535`        |
| `u24`  | `3 bytes`   | `0`            | `16,777,215`    |
| `u32`  | `4 bytes`   | `0`            | `4,294,967,295` |
| `u40`  | `5 bytes`   | `0`            | `2^40-1`        |
| `u48`  | `6 bytes`   | `0`            | `2^48-1`        |
| `u53`  | `7 bytes`   | `0`            | `2^53`          |

You can access each one with `light.datatypes.<Name>`.

The set of possible values is defined as `0` to `(2 ^ bits) - 1`.
