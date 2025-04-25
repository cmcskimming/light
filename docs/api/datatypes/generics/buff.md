# Buffers

Represents a
<a href="https://create.roblox.com/docs/reference/engine/libraries/buffer" target="_blank">`#!luau buffer`</a>.

Includes an optional Datatype for length, which defaults to
[`vlq(3)`](./vlq.md). The length datatype should NOT be a regular
number—instead: use a datatype that represents a number, like a
[`uint`](https://light.ardi.gg/api/datatypes/numbers/uints/), or
[`range`](https://light.ardi.gg/api/datatypes/generics/range/).

## `#!luau function light.datatypes.buff`

```luau title='<!-- client --> <!-- server --> <!-- shared --> <!-- sync -->'
function buff(
    length: Datatype<number>?
): Datatype<buffer>
```

A couple of ways you could use the optional `length` parameter:

```luau
local types = light.datatypes

local some_buff = types.buff( types.u8 ) -- Buffer between 0-255 bytes
```

```luau
local some_buff = types.buff( types.range(0, 50) ) -- Buffer should be between 0 and 50 bytes.
```

```luau
local some_buff = types.buff( types.literal(3) ) -- A buffer with 3 bytes.
```
