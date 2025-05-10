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
local datatypes = require("./include/datatypes/main.h")
local datatypes_types = require("./include/datatypes/types")
local lib_internal = require("./lib_internal.h")
local report = require("./report")

type Datatype<T = any> = datatypes_types.Datatype<T>

local function MISSING_IMPL(): any
	error(report.bug(report.problem("MISSING IMPLEMENTATION", 2)))
end

local lib = {}

lib.datatypes = datatypes
lib.internal = lib_internal

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
function lib.stfu(shut_up: boolean?): ()
	return MISSING_IMPL()
end

--[=[
The recommended and easy way to group together messages in light by name.

Container inputs should be a map of string message-names to any valid Datatype. This includes Datatypes like arrays or
maps that are defined with luau tables. I.e., { light.datatypes.u8 }

Client Overload

```luau
function container<MessageNames>(--Sync--Yields--
    message_names: MessageNames, -- { [string]: Datatype }
    namespace: string?
): (MessageNames)
```

Server Overload

```luau
function container<MessageNames>(--Sync--
    message_names: MessageNames, -- { [string]: Datatype }
    namespace: string?
): (MessageNames)
```

[Learn More](https://light.ardi.gg/api/network/messages/creation/container/)
]=]
function lib.container<MessageNames>(message_names: MessageNames, namespace: string?): MessageNames
	return MISSING_IMPL()
end

--[=[
Does the same thing as a [container](https://light.ardi.gg/api/network/messages/creation/container/), but doesn't force
you to put it in a string map. Input template should be any valid Datatype. This includes Datatypes like arrays or maps
that are defined with luau tables. I.e., message("abc", { light.datatypes.u8 })

Client Overload

```luau
function message<Data>(--Sync--Yields--
    name: string,
    template: Datatype<Data>
): (Message<Data>)
```

Server Overload

```luau
function message<Data>(--Sync--
    name: string,
    template: Datatype<Data>
): (Message<Data>)
```

[Learn More](https://light.ardi.gg/api/network/messages/creation/message/)
]=]
function lib.message<MessageData>(name: string, template: Datatype<MessageData>): MessageData
	return MISSING_IMPL()
end

return lib
