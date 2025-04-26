# Variable Length Quantity

<a href="https://en.wikipedia.org/wiki/Variable-length_quantity" target="_blank">Variable Length Quantities</a>
represent a set of arbitrarily sized [unsigned integers](../numbers/uints.md).

A VLQ takes less space for generally "smaller" numbers, so it can allow you to save on space if you don't know the size
of a number ahead of time. There is an optional `max_bytes` parameter to limit the number of bytes it can occupy,
defaulting to 7.

## `#!luau function light.vlq`

```luau title='<!-- client --> <!-- server --> <!-- shared --> <!-- sync -->'
function light.vlq(
    max_bytes: number?
): Datatype<number>
```

Returns a variable length number [Datatype](../index.md#what-is-a-datatype).

You can use this table to guage how large of a VLQ you should use, or to find out how many bytes a given integer is
going to occupy.

## Size Index

| `max_bytes` | Size        | Maximum Int                   | Minimum Int |
| ----------: | :---------- | ----------------------------- | ----------- |
| vlq(1)      | 1 byte      | 127`(128^1)-1`                | 0           |
| vlq(2)      | 1-2 byte(s) | 16,383`(128^2)-1`             | 0           |
| vlq(3)      | 1-3 byte(s) | 2,097,151`(128^3)-1`          | 0           |
| vlq(4)      | 1-4 byte(s) | 268,435,455`(128^4)-1`        | 0           |
| vlq(5)      | 1-5 byte(s) | 34,359,738,367`(128^5)-1`     | 0           |
| vlq(6)      | 1-6 byte(s) | 4,398,046,511,103`(128^6)-1`  | 0           |
| vlq(7)      | 1-7 byte(s) | 140,737,488,355,327`(2^47)-1` | 0           |
| vlq(8)      | N/A         | N/A`(N/A)`                    | N/A         |

## Why `2^47-1` for `#!luau vlq(7)`? <small>(Technical Details)</small>

Luau can accurately store an integer as high as `2^53`, but no higher. Internally, VLQs require an extra bit for every
seven bits of your number in order for them to show that they "continue" afterward. When a VLQ is serialized, it is
assembled as a single number, then written all at once. Considering we need 6 continuation bits to represent the
maximum, we can use the formula <nobr>`2 ^ (53 - 6) - 1`</nobr> as the highest possible value without exceeding a 2 ^ 53
bitwidth. If the implementation changes in the future, the limitation could be removed.
