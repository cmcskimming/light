# Datatypes

## What is a Datatype?

A datatype is something that represents some set of possible values. When you're sending something across the network
with light, you'll need to define what you want that thing to look like. Light has <em>a lot</em> of tools for doing
just that, but here's an example of one of the primitive number Datatypes:

[`#!luau local u8 = light.datatypes.u8`](./numbers/uints.md)

The prefix `u` indicates the number should be "unsigned"; greater than zero. The number to the right, `8`, is the number
of "bits"[^1] the value will take up across the network. A u8 can represent any value
<nobr>between `0` and `255`</nobr>

!!! tip

## Lying to luau

Generally, places where you see `#!luau Datatype<T>` in these docs, you will only see `#!luau T` or a type in your
editor. Generally, this avoids causing problems with Luau's type system.

[^1]:

    8 bits is also known as a byte. <nobr>`#!luau local bytes = bits // 8`</nobr> &
    <nobr>`#!luau local bits = 8·bytes`</nobr>
