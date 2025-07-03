# Cached

In light, [you can use lua table syntax](./tables/index.md) to represent a [Datatype](../index.md#what-is-a-datatype),
and it'll be converted automatically when you use it in a Message.

This API exists to manually cache the result of a [Datatype](../index.md#what-is-a-datatype). This will internally turn
it into a numeric ID if it isn't one already, rendering it unusable for anything other than ser/des and messages.
Messages cache their [Datatypes](../index.md#what-is-a-datatype) automatically, but using this can give you extra
performance.

## `#!luau function light.datatypes.cached`

```luau title='<!-- shared --> <!-- sync -->'
function cached<T>(
   value: Datatype<T>
): (Datatype<T>)
```
