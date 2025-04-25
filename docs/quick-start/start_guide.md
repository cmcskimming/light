# How do I get started?

For now, I'm going to place light's `ModuleScript` in `ReplicatedStorage`, but you can place it anywhere.
There are three ways to use light's functions, properties, etc:

- `#!luau local light = require(ReplicatedStorage.light).shared`
   This should be used when defining messages in a `ModuleScript`
- `#!luau local light = require(ReplicatedStorage.light).client`
   This should be used when sending or recieving messages on the client. I.e., inside a `LocalScript`.
- `#!luau local light = require(ReplicatedStorage.light).server`
   This should be used for sending/recieving messages on the server. I.e., inside a `Script`.

## <small>What is a </small><b>Message</b>?

"Message" is light's word for an event which can be fired to and from the server, and connected with a single callback.

## <small>What is a </small><b>Datatype</b>?

A datatype is something that represents some set of possible values. When you're sending something across the network
with light, you'll need to define what you want that thing to look like. This gives you access to a lot of neat
optimizations and quality of life features! Here's an example of one of light's many numeric datatypes:

`#!luau local u8 = light.datatypes.u8`

The prefix `u` means the number is unsigned <small>(should be greater than zero)</small>. The number to the right, `8`,
is the number of "bits"[^1] the value will take up across the network. The maximum value for an unsigned integer is
`(256 ^ (bits/8)) - 1`. So, we should be able to represent any value between `0` and `255` with a `u8`.

## How do I create Messages?

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

## Sending Messages <small>(from Client to Server)</small>

To send a message from the client to the server, use
[`#!luau light.send(message, data)`](../api/network/messages/sending/send.md)

```luau title="StarterPlayerScripts.client (LocalScript)"
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local light = require(ReplicatedStorage.light).client
local messages = require(ReplicatedStorage.messages)

light.send(messages.ping)
```

## Listening For Messages <small>(on The Server)</small>

Now, we need somewhere to listen for this message. The way to listen for a message being sent is with
[`#!luau light.connect(message, callback)`](../api/network/messages/listening/connect.md)

```luau title="ServerScriptService.server (Script)"
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local light = require(ReplicatedStorage.light).server
local messages = require(ReplicatedStorage.messages)

light.connect(messages.ping, function(player)
    print("pong!")
end)
```

## Sending Messages <small>(from Server to Client)</small>

With [`#!luau light.send()`](../api/network/messages/sending/send.md), we can modify our Script from before to respond
to ping:

```luau title="ServerScriptService.server (Script)"
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local light = require(ReplicatedStorage.light).server
local messages = require(ReplicatedStorage.messages)

light.connect(messages.ping, function(player)
    light.send(messages.ping, player)
end)
```

## Listening to Messages <small>(on The Client)</small>

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

[^1]:

    8 bits is also known as a byte. `#!luau local bytes = bits // 8` & `#!luau local bits = 8·bytes`
