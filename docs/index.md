---
hide:
  - navigation
  - feedback
---

# <span style="font-family:Comic Neue; font-weight:900">:3c</span>

Light is a *light*weight, robust, and secure remote wrapper for roblox. Read below, or [get started](quick-start/index.md).
<br>If you like Light or find it interesting, consider [leaving a ⭐](https://light.ardi.gg/github) to save it for later, or watching the repository.

## What Light does

- Batching, to pack all of your data efficiently together each frame.

- Serializes your data into buffers with static type validation, so you always get the **type** you expect.

- Lets you send large unreliable messages unrestricted, for tasks such as character replication or neck cframes.

- Works with no plugin or compiler. Light can be downloaded and used out-of-the-box.

- Security as a first-class feature, catch bad actors with security hooks, and actions.

- Handles all the RemoteEvent instances for you reliably.

## What Light doesn't

- Serve as a drop-in replacement for other tools, such as RemoteEvents,
<a href="https://github.com/ffrostfall/ByteNet" target="_blank">ByteNet</a>,
or <a href="https://github.com/1Axen/blink" target="_blank">Blink</a>.
Light is similar to these, but will require some work to migrate to/from.

- Secure your messages for you.
Static serialization ensures you get the types you expect, but the data can still be manipulated by exploiters.

- Provide a built-in signal implementation.
Light messages can only be connected or disconnected with a single callback. For convenience, a thread reuse
implementation is packaged out-of-the-box with [`#!luau light.connect()`](./api/network/messages/listening/connect.md)
[why?](#q-why-only-allow-one-callback)

## FAQ / Q&A

### Q: Does batching add extra delays or bandwidth overhead to my networking?

No. Roblox does batching on its own, light does batching to group messages together and optimize bandwidth.

### Q: Is event order the same as roblox?

No. Messages will be ordered per-message-name. This means that if you send 2 kinds of messages in the same frame, you
may end up with 2 contiguous lists of calls for each type:

```luau
send(message_a)
send(message_b)
send(message_a)
```

The other side will receive the first call to message a, the second call to message a, and then the call(s) to message
b. If you use <a href="https://github.com/ffrostfall/BridgeNet2" target="_blank">BridgeNet2</a>, you're already
experiencing this.

### Q: Why only allow one callback?

"Message" in Light indicates that there's an intended target or consumer, meaning the message "knows" about its
callback. Handling it this way solves a lot of edge cases. To make an event instead, you (can) make a wrapper which pipes
the message into a signal implementation or set of known callbacks. If you're interested in
profiling, the docs for [`#!luau light.disconnect()`](./api/network/messages/listening/disconnect.md) have a decent
example of an event profiler.

### Q: Where can I find holy?

Holy is available on [its github repo](https://placeholder.gg/).

## Special Thanks

Special thanks to
<a href="https://github.com/1Axen/blink" target="_blank">Blink</a>,
<a href="https://github.com/ffrostfall/ByteNet" target="_blank">ByteNet</a>,
<a href="https://github.com/Data-Oriented-House/Squash" target="_blank">Squash</a>,
and the people behind them. All of the above tools are awesome and you should absolutely check them out if you haven't
already. These tools have contributed and continue to contribute to The Roblox Networking Ecosystem. Light wouldn't be
possible without time and work from a lot of awesome people. I'd also like to personally thank the people below, as well
as anyone else who contributes to light:

- <a href="https://github.com/alicesaidhi/" target="_blank">Alice</a>: Holy-Light Icon
- <a href="https://github.com/lewisakura/" target="_blank">Lewi</a>: Helped develop docs :pray:
- <a href="https://github.com/gurrrrrrett3/" target="_blank">Max</a>: Ported docs/types to roblox-ts
