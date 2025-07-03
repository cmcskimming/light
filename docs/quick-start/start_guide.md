# How do I get started?

For now, I'm going to place light's `ModuleScript` in `ReplicatedStorage`, but you can place it anywhere.
There are three ways to use light's functions, properties, etc:

`#!luau local light = require(ReplicatedStorage.light).shared--(1)!`
{.annotate}

1. This should be used when writing code for the client <em>and</em> the server, E.g., a `ModuleScript`.

`#!luau local light = require(ReplicatedStorage.light).client--(1)!`
{.annotate}

1. This should be used when writing code for the <em>client</em>. E.g., inside a `LocalScript`.

`#!luau local light = require(ReplicatedStorage.light).server--(1)!`
{.annotate}

1. This should be used for writing code for the <em>server</em>. E.g., inside a `Script`.

## <small><em>What</em> is a </small><b>Message</b>?

A "Message" is an event which can be fired to and from the server, and connected with a single callback.

## <small><em>What</em> is a </small><b>Datatype</b>?

A datatype is something that represents some set of possible values. When you're sending something across the network
with light, you'll need to define what you want that thing to look like. Here's an example of one of light's number
Datatypes:

`#!luau local u8 = light.datatypes.u8`

The prefix `u` indicates the number is an unsigned integer <small>(whole numbers greater than zero.)</small> The number to the right,
`8`, is the number of "bits"[^1] the value will take up across the network. A u8 can represent any value
<nobr>between `0` and `255`</nobr>

[^1]:

    8 bits is also known as a byte. Bytes are generally a measurement we use to talk about how much space something
    takes to represent inside a computer.

    <nobr>`#!luau local bytes = bits // 8`</nobr> & <nobr>`#!luau local bits = 8 · bytes`</nobr>

!!!tip "Unsigned Integers"

    The maximum value for an unsigned integer can be calculated with <nobr>`(256 ^ (bits / 8) ) - 1`</nobr>

## How do I <em>create</em> Messages?

Light lets you define a Datatype for every Messae you create. Assuming you do, you'll get good autocomplete and will
<b>never</b> need to make sure the type of your data is correct from inside a Message's callback. Light handles it all
for you in an optimized way. The recommended way to create messages is with a simple ModuleScript:

```luau title="ReplicatedStorage.abc_messages <small>(ModuleScript)</small>"
local light = require(ReplicatedStorage.light).shared

local types = light.datatypes

local container = light.container({--(1)!
    ping = types.literal(nil),--(2)!
}, "abc")

light.begin_replication()--(3)!

return container
```

1. `#!luau light.container(messages)` creates a "list" of messages from the table provided so the messages can be used.

2. `#!luau types.literal(nil)` means that the message doesn't contain any data, because it is literally `#!luau nil`.

3. `#!luau light.begin_replication()` Can be called at any time to allow messages to be sent on the client or server,
but it's best to get it out of the way. Calling multiple times or from multiple files has no additional effects. If you
call it later on, all of the messages you try to send will still get queued up.

## Sending Messages <nobr><em><small>(from <b>Client</b> to <b>Server</b>)</small></em></nobr>

To send a message from the client to the server, use
`#!luau light.send(message, data)`

```luau title="StarterPlayerScripts.client (LocalScript)"
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local light = require(ReplicatedStorage.light).client
local messages = require(ReplicatedStorage.messages)

light.send(messages.ping)
```

## Listening For Messages <nobr><em><small>(on the <b>Server</b>)</small></em></nobr>

Now, we need somewhere to listen for this message. The way to listen for a message being sent is with
`#!luau light.connect(message, callback)`

```luau title="ServerScriptService.server (Script)"
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local light = require(ReplicatedStorage.light).server
local messages = require(ReplicatedStorage.messages)

light.connect(messages.ping, function(player)
    print("pong!")
end)
```

## Sending Messages <nobr><em><small>(from <b>Server</b> to <b>Client</b>)</small></em></nobr>

`#!luau light.send()`, we can modify our Script from before to respond
to ping:

```luau title="ServerScriptService.server (Script)"
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local light = require(ReplicatedStorage.light).server
local messages = require(ReplicatedStorage.messages)

light.connect(messages.ping, function(player)
    light.send(messages.ping, player)
end)
```

## Listening for Messages <nobr><em><small>(on the <b>Client</b>)</small></em></nobr>

Now let's change our LocalScript to listen to the server's response:

```luau title="StarterPlayerScripts.client (LocalScript)"
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local light = require(ReplicatedStorage.light).client
local messages = require(ReplicatedStorage.messages)

light.connect(messages.ping, function()
    print("pong!")
end)

light.send(messages.ping)
```
