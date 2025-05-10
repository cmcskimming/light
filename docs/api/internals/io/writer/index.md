# Dynamic Writer

Light exposes the ability to access internal serialization and deserialization with the input/output API. A dynamic
writer and the underlying API provides an interface for using light's features at a low level. You can create one with
[`#!luau light.internal.writer_from_buff()`](./writer_from_buff.md) or
[`#!luau light.internal.writer_from_size()`](./writer_from_size.md). You can write to them with
[`#!luau light.internal.input()`](../input.md) and read their data with
[`#!luau light.internal.output()`](../output.md).
