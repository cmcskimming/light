# Any

Represents a value which should be serialized with the format Roblox's Remote Events use.

!!!tip Consider alternatives

    Consider using [Instances](./instances.md) or [Checked](./generics/checked.md) over `any`. This is because `any`
    can't check that the type sent over the network is correct, and can be manipulated by exploiters.

!!!danger Unreliables

    Using this while [sending unreliably](../network/messages/sending/send_unreliably.md) can cause things to 
    consistently fail to send if the packet is too large.

## `#!luau local light.datatypes.any`

```luau title='<!-- client --> <!-- server --> <!-- shared -->'
local any: any
```
