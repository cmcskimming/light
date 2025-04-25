# Bool

Represents `true | false`.

Booleans <small>(for most intents and purposes)(1)</small> cost 1/8th of a byte to send over the network.
{.annotate}

1. To learn more about how Light's Bitpacking works, check out
   [The Internals Blog](../../blog/internals/bitpacks.md) on the topic.

## `#!luau local light.datatypes.bool`

```luau title='<!-- client --> <!-- server --> <!-- shared -->'
local bool: true | false
```
