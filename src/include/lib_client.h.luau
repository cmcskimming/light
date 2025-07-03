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
local datatypes_types = require("./datatypes/types")
local header_graph = require("./graph")
local lib_internal = require("./lib_internal.h").include()
local messages_types = require("../messages/types")
local report = require("../utils/report")

type MessageCallback<T = any> = messages_types.ClientCallback<T>
type Datatype<T = any> = datatypes_types.Datatype<T>

local function MISSING_IMPL(): any
	error(report.bug(report.problem("MISSING IMPLEMENTATION", 1)))
end

local client_lib = {}

client_lib.internal = lib_internal

--[=[
Silences serialization / deserialization errors and Datatype warnings.

```luau
function stfu(
	sybau: boolean
): ()
```

[Learn More](https://light.ardi.gg/api/stfu/)
]=]
function client_lib.stfu(sybau: boolean): ()
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
function client_lib.begin_replication(): ()
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
function client_lib.step_replication(): any
	return MISSING_IMPL()
end

--[=[
Sets an asynchronous callback for a given message when it is sent. A message can only have one connection, but you can
always connect your messages into a choice signal implementation.

Callbacks can be removed with [`disconnect`](https://light.ardi.gg/api/network/messages/listening/disconnect/).

```luau
function connect<Data>(--Sync--
	message: Message<Data>,
	callback: (Data) -> ()
): ()
```

[Learn More](https://light.ardi.gg/api/network/messages/listening/connect/)
]=]
function client_lib.connect<Data>(message: Data, callback: MessageCallback<Data>): ()
	return MISSING_IMPL()
end

--[=[
Does the same thing as [`connect`](https://light.ardi.gg/api/network/messages/listening/connect/) with one major
difference. Thread reuse will not be used with `connect_sync`, and the function will be called directly. This means if
you yield in your callback, you could get a buffer access out of bounds or cause other completely undefined behavior.

```luau
function connect_sync<Data>(--Sync--Errors--
	message: Message<Data>,
	callback: (Data) -> ()
): ()
```

[Learn More](https://light.ardi.gg/api/network/messages/listening/connect_sync/)
]=]
function client_lib.connect_sync<Data>(message: Data, callback: MessageCallback<Data>): ()
	return MISSING_IMPL()
end

--[=[
Removes a callback from a message. If there was a callback already connected, it'll be returned.

```luau
function disconnect<Data>(--Sync--
	message: Message<Data>
) -> (
	( (Data) -> () )?
)
```

[Learn More](https://light.ardi.gg/api/network/messages/listening/disconnect/)
]=]
function client_lib.disconnect<Data>(message: Data): ((Data) -> ())?
	return MISSING_IMPL()
end

--[=[
Send a message reliably to the server.

```luau
function send<Data>(--Sync--
	message: Message<Data>,
	input: Data
): ()
```

[Learn More](https://light.ardi.gg/api/network/messages/sending/send/)
]=]
function client_lib.send<Data>(message: Data, input: Data): ()
	return MISSING_IMPL()
end

--[=[
Send a message unreliably with no size limit to the server.

```luau
function send_unreliably<Data>(--Sync--
	message: Message<Data>,
	input: Data
): ()
```

[Learn More](https://light.ardi.gg/api/network/messages/sending/send_unreliably/)
]=]
function client_lib.send_unreliably<Data>(message: Data, data: Data): ()
	return MISSING_IMPL()
end

return header_graph:define(client_lib)
