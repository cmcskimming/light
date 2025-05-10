--[[MIT License Copyright (c) 2025 @hardlyardi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]
--[[
--FOR DESCRIPTIONS OF API & CODE FUNCTION, ETC: https://light.ardi.gg/
--FOR ISSUES, BUG REPORTS, OR FEATURE REQUESTS: https://light.ardi.gg/github
--ROBLOX OSS SERVER: https://discord.com/invite/5KjV64PA3d
--MY DISCORD (please only contact for important questions): https://discord.com/users/331399684415553538/
]]
do
end
local clients_types = require("./include/clients/types")
local datatypes_types = require("./include/datatypes/types")
local lib_internal = require("./lib_internal.h")
local messages_types = require("./messages/types")
local report = require("./report")

type Client = clients_types.Identity
type MessageCallback<T = any> = messages_types.ServerCallback<T>
type Datatype<T = any> = datatypes_types.Datatype<T>

local function MISSING_IMPL(): any
	error(report.bug(report.problem("MISSING IMPLEMENTATION", 1)))
end

local server_lib = {}

server_lib.internal = lib_internal

--[=[
Silences serialization / deserialization errors and Datatype warnings.

If no state is provided, will default to `shut_up = true`

```luau
function stfu(
	shut_up: boolean?
): ()
```

[Learn More](https://light.ardi.gg/api/stfu/)
]=]
function server_lib.stfu(shut_up: boolean?): ()
	return MISSING_IMPL()
end

--[=[
Can be called at any time to allow messages to be sent on the client or server, but it's best to get it out of the way.
Calling multiple times or from multiple files has no additional effects. If you call it later on, all of the messages
you try to send will still get queued up.

```luau
function begin_replication(--Sync--
): ()
```

[Learn More](https://light.ardi.gg/api/begin_replication/)
]=]
function server_lib.begin_replication(): ()
	return MISSING_IMPL()
end

--[=[
Manually step the network batch.

```luau
function step_replication(--Sync--
): ()
```

[Learn More](https://light.ardi.gg/api/step_replication/)
]=]
function server_lib.step_replication(): any
	return MISSING_IMPL()
end

--[=[
Sets an asynchronous callback for a given message when it is sent. A message can only have one connection, but you can
always connect your messages into a choice signal implementation.

Callbacks can be removed with [`disconnect`](https://light.ardi.gg/api/network/messages/listening/disconnect/).

```luau
function connect<Data>(--Sync--
    message: Message<Data>,
    callback: (Client, Data) -> ()
): ()
```

[Learn More](https://light.ardi.gg/api/network/messages/listening/connect/)
]=]
function server_lib.connect<Data>(message: Data, callback: MessageCallback<Data>): ()
	return MISSING_IMPL()
end

--[=[
Does the same thing as [`connect`](https://light.ardi.gg/api/network/messages/listening/connect/) with one major
difference. Thread reuse will not be used with `connect_sync`, and the function will be called directly. This means if
you yield in your callback, you could get a buffer access out of bounds or cause other completely undefined behavior.

```luau
function connect_sync<Data>(--Sync--Errors--
    message: Message<Data>,
    callback: (Client, Data) -> ()
): ()
```

[Learn More](https://light.ardi.gg/api/network/messages/listening/connect_sync/)
]=]
function server_lib.connect_sync<Data>(message: Data, callback: MessageCallback<Data>): ()
	return MISSING_IMPL()
end

--[=[
Removes a callback from a message. If there was a callback already connected, it'll be returned.

```luau
function disconnect<Data>(
   message: Message<Data>
) -> (
   ( (Client, Data) -> () )?
)
```
]=]
function server_lib.disconnect<Data>(message: Data): ((Client, Data) -> ())?
	return MISSING_IMPL()
end

--[=[
Send a message reliably to a specific client.

```luau
function send<T>(--Sync--
	message: Message<T>,
	to: Client,
	data: T
): ()
```

[Learn More](https://light.ardi.gg/api/network/messages/sending/send/)
```
]=]
function server_lib.send<Data>(message: Data, to: Client, input: Data): ()
	return MISSING_IMPL()
end

--[=[
Sends a message reliably to a list of clients.

```luau
function broadcast<Data>(
	message: Message<Data>,
	to: { Player },
	input: Data
)
```

[Learn More](https://light.ardi.gg/api/network/messages/sending/broadcast/)
]=]
function server_lib.broadcast<Data>(message: Data, to: { Client }, input: Data): ()
	return MISSING_IMPL()
end

--[=[
Sends a message reliably to all clients.

```luau
function broadcast_to_all<Data>(
	message: Message<Data>,
	input: Data
)
```

[Learn More](https://light.ardi.gg/api/network/messages/sending/broadcast_to_all/)
]=]
function server_lib.broadcast_to_all<Data>(message: Data, input: Data): ()
	return MISSING_IMPL()
end

--[=[
Sends a message reliably to all clients except a client or list of clients.

```luau
function broadcast_to_all_except<Data>(
	message: Message<Data>,
	except: Client | { Client },
	input: Data
)
```

[Learn More](https://light.ardi.gg/api/network/messages/sending/broadcast_to_all_except/)
]=]
function server_lib.broadcast_to_all_except<Data>(
	message: Data,
	except: Client | { Client },
	input: Data
): ()
	return MISSING_IMPL()
end

--[=[
Send a message unreliably with no size limit to a specific client.

```luau
function send_unreliably<Data>(--Sync--
	message: Message<Data>,
	to: Client,
	input: Data
): ()
```

[Learn More](https://light.ardi.gg/api/network/messages/sending/send_unreliably/)
]=]
function server_lib.send_unreliably<Data>(message: Data, to: Client, input: Data): ()
	return MISSING_IMPL()
end

--[=[
Sends a message unreliably with no size limit to a list of clients.

```luau
function broadcast_unreliably<Data>(
	message: Message<Data>,
	to: { Player },
	input: Data
)
```

[Learn More](https://light.ardi.gg/api/network/messages/sending/broadcast_unreliably/)
]=]
function server_lib.broadcast_unreliably<Data>(message: Data, to: { Client }, input: Data): ()
	return MISSING_IMPL()
end

--[=[
Sends a message unreliably with no size limit to all clients.

```luau
function broadcast_unreliably_to_all<Data>(
	message: Message<Data>,
	input: Data
)
```

[Learn More](https://light.ardi.gg/api/network/messages/sending/broadcast_unreliably_to_all/)
]=]
function server_lib.broadcast_unreliably_to_all<Data>(message: Data, input: Data): ()
	return MISSING_IMPL()
end

--[=[
Sends a message unreliably with no size limit to all clients except a client or list of clients.

```luau
function broadcast_unreliably_to_all_except<Data>(
	message: Message<Data>,
	except: Client | { Client },
	input: Data
)
```

[Learn More](https://light.ardi.gg/api/network/messages/sending/broadcast_unreliably_to_all_except/)
]=]
function server_lib.broadcast_unreliably_to_all_except<Data>(
	message: Data,
	except: Client | { Client },
	input: Data
): ()
	return MISSING_IMPL()
end

return server_lib
