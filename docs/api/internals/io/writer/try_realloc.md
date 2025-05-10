# Try Realloc

Makes sure a valid [DynamicWriter](./index.md) has the amount of space specified, resizing the buffer if necessary.

!!! danger "The buffer may change"

    After calling [`#!luau light.internal.try_realloc()`](./try_realloc.md), the buffer the writer contains may change
    because it had to be resized. Do not hold onto buffers when using this API. Each time you call it, the only
    safe way to get the buffer is with [`#!luau light.io.get_writer_buff()`](./get_writer_buff.md).

## `#!luau function light.internal.try_realloc()`

```luau title='<!-- client --> <!-- server --> <!-- shared --> <!-- experimental --> <!-- sync -->'
function try_realloc(
    writer: DynamicWriter,
    target_ptr: number
): ()
```
