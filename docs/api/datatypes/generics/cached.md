# Cached

In light, [you can use lua table syntax](./tables/index.md) to represent a [Datatype](../index.md#what-is-a-datatype), and it'll be
converted automatically when you use it in a Message.

This API exists to manually cache the result of a [Datatype](../index.md#what-is-a-datatype). This will internally turn it into a numeric
ID if it isn't one already, rendering it unusable for anything other than ser/des and messages. Messages cache their
[Datatypes](../index.md#what-is-a-datatype) automatically, but this can be useful in conjunction with other features like
[Computed Datatypes](./computed.md).

## `#!luau function light.datatypes.cached`

```luau title='<!-- client --> <!-- server --> <!-- shared --> <!-- sync -->'
function cached<T>(
   value: Datatype<T>
): Datatype<T>
```

An example
<a href="https://en.wikipedia.org/wiki/Linked_list" target="_blank">LinkedList</a> [Datatype](../index.md#what-is-a-datatype)
using [`#!luau datatypes.cached()`](./cached.md) and [`#!luau datatypes.computed()`](./computed.md):

```luau title="linked_list.luau"
local types = datatypes

-- as a word of warning, you probably shouldn't give this a `head` field.
local function linkedlist<T>(value: Datatype<T>)
   local Datatype

   Datatype = types.cached {
      next = types.optional(types.computed(function()
         return Datatype
      end)),
      
      value = value
   }

   return Datatype
end

return linkedlist
```

!!! danger "[`#!luau light.computed()`](./computed.md) allows for recursive types."

    If you pass a self-referential table, serialization may hang forever.
