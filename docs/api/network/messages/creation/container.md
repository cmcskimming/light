# Containers

Containers are the recommended and easy way to group together messages in light by name.

Container inputs should be a map of string message-names to any valid [Datatype](../../../datatypes/index.md#what-is-a-datatype).
This includes [Datatypes](../../../datatypes/index.md#what-is-a-datatype) like arrays or maps that are defined with luau tables.
E.g., `#!luau { light.datatypes.u8 }`

!!! info "If messages inside are already synchronized beforehand, the container will not yield."

    The server defines the messages immediately, so `#!luau container {...}` will never yield on the server.

## `#!luau function light.container` <small>(On The Client)</small>

```luau title='<!-- shared --> <!-- sync --> <!-- async -->'
function container<MessageNames>(
    message_names: MessageNames, -- { [string]: Datatype }
    namespace: string? --(1)!
): (MessageNames)
```

## `#!luau function light.container` <small>(On The Server)</small>

```luau title='<!-- shared --> <!-- sync -->'
function container<T>(
    message_names: T, -- { [string]: Datatype }
    namespace: string?
): (T)
```

!!!tip "Namespaces don't impact behavior"

    Namespaces do not impact message ordering whatsoever in light. They are entirely cosmetic, allowing you to have
    multiple containers with overlapping message names.

Some example code using containers:

```luau
local light = require(ReplicatedStorage.light).shared

local ty = light.datatypes

return light.container({
    abc = { ty.u8 }, -- send a table of u8 numbers
}, "some-cool-namespace")
```

!!! tip "You can replicate the above code 1:1 with [`#!luau light.message()`](./message.md)"
