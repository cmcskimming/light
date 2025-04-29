# Send

Allows you to send a message to a specific target.

## `#!luau function light.send`

```luau title='<!-- client --> <!-- sync -->'
function send<T>(
    message: Message<T>,
    data: T
): ()
```

```luau title='<!-- server --> <!-- sync -->'
function send<T>(
    message: Message<T>,
    to: Player,
    data: T
): ()
```

## On the Client

Send a message with given data to the server, for example:

```luau
light.send(messages.abc, 123)
```

## On The Server

Send a message with given data to a player, for example:

```luau
Players.PlayerAdded:Connect(function(player)
    light.send(messages.abc, player, 123)
end)
```

!!! tip "Sending messages to multiple people"

    To send messages to multiple people on the server, check out [`#!luau light.broadcast()`](./broadcast.md).
