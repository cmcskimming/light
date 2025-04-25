# Datatypes

## What is a Datatype?

A datatype is something that represents some set of possible values. When you're sending something across the network
with light, you'll need to define what you want that thing to look like. Light has a lot of tools for doing that, which
is what this section is all about. Here's an example of one of the number Datatypes:

[`#!luau local u8 = light.datatypes.u8`](./numbers/uints.md),

`u` means the number should be "unsigned"; greater than zero. The number to the right, `8`, means the datatype
represents something which costs exactly 8 bits[^1] to send. The maximum value for an unsigned integer is `(2 ^ bits) - 1` or
`(256 ^ bytes) - 1`. If we apply this to a `u8`, we should be able to send any value `0` to `255`.

## Lying to luau

Generally, places where you see `#!luau Datatype<T>` in these docs, you will only see `#!luau T` or a type in your
editor. Generally, this avoids causing problems with Luau's type system.

[^1]:

    8 bits is also known as a byte. `#!luau local bytes = bits // 8` & `#!luau local bits = 8·bytes`
