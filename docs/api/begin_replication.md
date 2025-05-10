# Begin Replication

`#!luau function light.begin_replication()` Can be called at any time to allow messages to be sent on the client or
server, but it's best to get it out of the way. Calling multiple times or from multiple files has no additional effects.
If you call it later on, all of the messages you try to send will still get queued up.

## `#!luau function light.begin_replication`

```luau title='<!-- client --> <!-- server --> <!-- shared --> <!-- sync -->'
function begin_replication(
): ()
```

You can use [`#!luau light.step_replication()`](./step_replication.md) instead of this if you prefer a manual
replication step.
