# Connect

Connect sets a callback for a given message when it is sent. A message can only have one connection, but you can always
connect your messages into a choice signal implementation. Callbacks can be removed with
[`#!luau light.disconnect()`](./disconnect.md). Message callbacks will be spawned asynchronously with thread reuse. To
create a non-yielding callback you can use [`#!luau light.connect_sync()`](./connect_sync.md)

!!! tip "This function can error if there is already a callback connected."

    Consider calling [`#!luau light.disconnect()`](./disconnect.md) first if this is an issue.

## `#!luau function light.connect`

```luau title='<!-- client --> <!-- sync --> <!-- errors -->'
function connect<Data>(
    message: Message<Data>,
    callback: (Data) -> ()
): ()
```

## `#!luau function light.connect`

```luau title='<!-- server --> <!-- sync --> <!-- errors -->'
function connect<Data>(
    message: Message<Data>,
    callback: (Player, Data) -> ()
): ()
```

Some example code using [`#!luau light.connect()`](./connect.md):

```luau
light.connect(messages.ping, function(player)
    print("pong!")
end)
```
