# Signed Integers

Signed Integers represent a number which is divisible by one and could be negative.

You can tell a [Datatype](../index.md#what-is-a-datatype) represents a signed integer if its name has the `i` prefix.
The number afterward tells you how many bits the [Datatype](../index.md#what-is-a-datatype) costs to send over the network.

## Size Index

| Name   | Size      | Maximum Int       | Minimum Int       |
| -----: | :-------- | ----------------- | ----------------- |
| `i8`   | `1 byte`  | `127`             | `- 128`           |
| `i16`  | `2 bytes` | `32,767`          | `- 32,768`        |
| `i24`  | `3 bytes` | `8,388,607`       | `- 8,388,608`     |
| `i32`  | `4 bytes` | `2,147,483,647`   | `- 2,147,483,648` |
| `i40`  | `5 bytes` | `2^39 - 1`        | `- 2^39`          |
| `i48`  | `6 bytes` | `2^47 - 1`        | `- 2^47`          |
| `i54`  | `7 bytes` | `2^53`            | `- 2^53`          |

You can access each one with `light.datatypes.<Name>`.

The set of possible values is defined as `-2 ^ (bits - 1)` to `2 ^ (bits - 1) - 1`.
