# Signed Integers

Signed Integers represent a number which is divisible by one and could be negative.

You can tell a [Datatype](../index.md#what-is-a-datatype) represents a signed integer if its name has the `i` prefix.
The number afterward tells you how many bits the [Datatype](../index.md#what-is-a-datatype) uses to represent values
sent over the network.

## Size Index

| Name   | Size      | Maximum Int                                      | Minimum Int                                      |
| -----: | :-------- | ------------------------------------------------ | ------------------------------------------------ |
| `i8`   | `1 byte`  | `(2^7)-1`<small>(127)</small>                    | `-(2^7)`<small>(-128)</small>                    |
| `i16`  | `2 bytes` | `(2^15)-1`<small>(32,767)</small>                | `-(2^15)`<small>(-32,768)</small>                |
| `i24`  | `3 bytes` | `(2^23)-1`<small>(8,388,607)</small>             | `-(2^23)`<small>(-8,388,608)</small>             |
| `i32`  | `4 bytes` | `(2^31)-1`<small>(2,147,483,647)</small>         | `-(2^31)`<small>(-2,147,483,648)</small>         |
| `i40`  | `5 bytes` | `(2^39)-1`<small>(549,755,813,887)</small>       | `-(2^39)`<small>(-549,755,813,888)</small>       |
| `i48`  | `6 bytes` | `(2^47)-1`<small>(140,737,488,355,327)</small>   | `-(2^47)`<small>(-140,737,488,355,328)</small>   |
| `i53`  | `7 bytes` | `(2^53)-1`<small>(9,007,199,254,740,991)</small> | `-(2^53)`<small>(-9,007,199,254,740,992)</small> |

You can access each one with `light.datatypes.<Name>`.

The set of possible values is defined as `-2 ^ (bits - 1)` to `2 ^ (bits - 1) - 1`.
