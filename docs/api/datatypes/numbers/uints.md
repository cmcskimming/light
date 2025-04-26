# Unsigned Integers

Unsigned Integers represent a whole number which is greater than or equal to zero. For numbers with decimal places, you
should use a [Float](./floats.md).

You can tell a [Datatype](../index.md#what-is-a-datatype) represents an unsigned integer if its name has the `u` prefix.
The number afterward tells you how many bits the [Datatype](../index.md#what-is-a-datatype) costs to send over the network.

## Size Index

| Name   | Size        | Maximum Int     | Minimum Int    |
| -----: | :---------- | --------------- | -------------- |
| `u8`   | `1 byte`    | `255`           | `0`            |
| `u16`  | `2 bytes`   | `65,535`        | `0`            |
| `u24`  | `3 bytes`   | `16,777,215`    | `0`            |
| `u32`  | `4 bytes`   | `4,294,967,295` | `0`            |
| `u40`  | `5 bytes`   | `2^40 - 1`      | `0`            |
| `u48`  | `6 bytes`   | `2^48 - 1`      | `0`            |
| `u53`  | `7 bytes`   | `2^53`          | `0`            |

You can access each one with `light.datatypes.<Name>`.

The set of possible values is defined as `0` to `(2 ^ bits) - 1`.
