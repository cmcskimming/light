# Variable Length Quantity

<a href="https://en.wikipedia.org/wiki/Variable-length_quantity" target="_blank">Variable Length Quantities</a>
represent a set of arbitrarily sized [unsigned integers](../numbers/uints.md).

A VLQ takes less space for generally "smaller" numbers, so it can allow you to save on space if you don't know the size
of a number ahead of time. There is an optional `max_bytes` parameter to limit the number of bytes it can occupy,
defaulting to 7.

## `#!luau function light.datatypes.vlq`

```luau title='<!-- shared --> <!-- sync -->'
function vlq(
    max_bytes: number?
): Datatype<number>
```

Returns a variable length number [Datatype](../index.md#what-is-a-datatype).

You can use this table to guage how large of a VLQ you should use, or to find out how many bytes a given integer is
going to occupy.

## Size Index

| `max_bytes` | Size        | Maximum Int                                         | Minimum Int |
| ----------: | :---------- | --------------------------------------------------- | ----------- |
| vlq(1)      | 1 byte      | `(128^1)-1` <small>(127)</small>                    | 0           |
| vlq(2)      | 1-2 byte(s) | `(128^2)-1` <small>(16,383)</small>                 | 0           |
| vlq(3)      | 1-3 byte(s) | `(128^3)-1` <small>(2,097,151)</small>              | 0           |
| vlq(4)      | 1-4 byte(s) | `(128^4)-1` <small>(268,435,455)</small>            | 0           |
| vlq(5)      | 1-5 byte(s) | `(128^5)-1` <small>(34,359,738,367)</small>         | 0           |
| vlq(6)      | 1-6 byte(s) | `(128^6)-1` <small>(4,398,046,511,103)</small>      | 0           |
| vlq(7)      | 1-7 byte(s) | `(128^7)-1` <small>(562,949,953,421,311)</small>    | 0           |
| vlq(8)      | 1-8 byte(s) | `(128^8)-1` <small>(72,057,594,037,927,935)</small> | 0           |
