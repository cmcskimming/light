# Range

Represents a range of possible integers by providing a minimum and maximum, then encoding / decoding the equivalent of
`#!luau math.clamp(input, minimum, maximum)`.

## `#!luau function light.datatypes.range`

```luau title='<!-- client --> <!-- server --> <!-- shared --> <!-- sync -->'
function range(
    minimum: number,
    maximum: number
): Datatype<number>
```

## Size

Will use the minimum number of bytes possible to represent the range of possible numbers:

| <a href="https://create.roblox.com/docs/reference/engine/libraries/math#abs" target="_blank">`#!luau math.abs(maximum - minimum) <= n`</a> | Size      |
| ------------------------------------------------------------------------------------------------------------------------------------------ | --------- |
| `n = 255`                                                                                                                                  | `1 Byte`  |
| `n = 65,535`                                                                                                                               | `2 Bytes` |
| `n = 16,777,215`                                                                                                                           | `3 Bytes` |
| `n = 4,294,967,295`                                                                                                                        | `4 Bytes` |
| `n = 2 ^ 40 - 1`                                                                                                                           | `5 Bytes` |
| `n = 2 ^ 48 - 1`                                                                                                                           | `6 Bytes` |
| `n = 2 ^ 56`                                                                                                                               | `7 Bytes` |
