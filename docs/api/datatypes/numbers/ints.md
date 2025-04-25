# Signed Integers

Signed Integers represent a number which is divisible by one and could be negative.

You can tell a datatype is a signed integer by the preceding `i` prefix. The number afterward tells you how many bits
the [Datatype](../index.md#what-is-a-datatype) costs to send over the network.

| Name   | Size      | Minimum Int      | Maximum Int     |
| -----: | :-------- | ---------------- | --------------- |
| `i8`   | `1 byte`  | `-128`           | `127`           |
| `i16`  | `2 bytes` | `-32,768`        | `32,767`        |
| `i24`  | `3 bytes` | `-8,388,608`     | `8,388,607`     |
| `i32`  | `4 bytes` | `-2,147,483,648` | `2,147,483,647` |
| `i40`  | `5 bytes` | `-2^39`          | `2^39-1`        |
| `i48`  | `6 bytes` | `-2^47`          | `2^47-1`        |

You can access each one with `light.datatypes.<Name>`.

The set of possible values is defined as `-2 ^ (bits - 1)` to `2 ^ (bits - 1) - 1`.
