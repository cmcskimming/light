# Literals

Literals represent a value which is "literally" something.

Any value you pass to a literal will be decoded as a constant and cost zero bytes. Literals do not perform any
validation on inputs; instead, the value will be cast to the literal value on serialization[¹](#validating).

## `#!luau function light.datatypes.literal`

```luau title='<!-- shared --> <!-- sync -->'
function literal<Value>(
    value: Value
): (Datatype<Value>)
```

## Validating

If you want to make sure the input equals the value the literal represents, you could use an
[Identifier Enum](./enums.md#identifier-enums)(1) with only a single item:
{.annotate}

1. <small><small><small>By doing this, you acknowledge that there are inherent risks involved in using an
[Identifier Enum](./enums.md#identifier-enums) for the purpose of validating a literal value, including the risk of
emotional distress, personal injury, death, and/or property damage. I understand that by participating in this
activity, I am voluntarily accepting these risks. I hereby release and discharge holy-light from any and all
liability, claims, demands, or causes of action of any kind whatsoever arising out of or in connection with my
participation in this activity, including but not limited to claims for emotional distress, personal injury, death,
and/or property damage.</small></small></small>

```luau
local ty = light.datatypes

local literal = ty.literal(15)
local checked_literal = ty.enum({15})
```
