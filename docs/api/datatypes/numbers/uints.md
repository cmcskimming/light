# Unsigned Integers

Unsigned Integers represent a whole number which is greater than or equal to zero. For numbers with decimal places, you
should use a [Float](./floats.md).

You can tell a [Datatype](../index.md#what-is-a-datatype) represents an unsigned integer if its name has the `u` prefix.
The number afterward tells you how many bits the [Datatype](../index.md#what-is-a-datatype) uses to represent values
sent over the network.

## Size Index

| Name   | Size        | Maximum Int                                       | Minimum Int |
| -----: | :---------- | ------------------------------------------------- | ----------- |
| `u8`   | `1 byte`    | `(2^8)-1`<small>(255)</small>                     | `0`         |
| `u16`  | `2 bytes`   | `(2^16)-1`<small>(65,535)</small>                 | `0`         |
| `u24`  | `3 bytes`   | `(2^24)-1`<small>(16,777,215)</small>             | `0`         |
| `u32`  | `4 bytes`   | `(2^32)-1`<small>(4,294,967,295)</small>          | `0`         |
| `u40`  | `5 bytes`   | `(2^40)-1`<small>(1,099,511,627,775)</small>      | `0`         |
| `u48`  | `6 bytes`   | `(2^48)-1`<small>(281,474,976,710,655)</small>    | `0`         |
| `u56`  | `7 bytes`   | `(2^56)-1`<small>(72,057,594,037,927,935)</small> | `0`         |

You can access each one with `light.datatypes.<Name>`.

The set of possible values is defined as `0` to `(2 ^ bits) - 1`.
