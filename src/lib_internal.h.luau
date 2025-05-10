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
--[[
This file is a user interface for the internals of the library, giving users access to more powerful features while
allowing me to make breaking changes.
]]
do
end
local lib_internal_types = require("./lib_internal_types")
local light_types = require("./types")
local report = require("./report")

type HolyApi = lib_internal_types.HolyApi
type Datatype<T = any> = light_types.LightDatatype<T>
type DynamicWriter = lib_internal_types.DynamicWriter

local function MISSING_IMPL(): any
	error(report.bug(report.problem("MISSING IMPLEMENTATION", 1)))
end

local internal_lib = {}

--[=[
Allows you to use light's internal serialization on your own
[DynamicWriter](https://light.ardi.gg/api/internals/io/writer/).

```luau
function input<Data>(--Errors--Experimental--Sync--
	writer: DynamicWriter,
	type: Datatype<Data>,
	data: T
): ()
```

[Learn More](https://light.ardi.gg/api/internals/io/input/)
]=]
function internal_lib.input<Data>(writer: DynamicWriter, type: Datatype<Data>, data: Data): ()
	return MISSING_IMPL()
end

--[=[
Allows you to use light's internal deserialization on your own
[DynamicWriter](https://light.ardi.gg/api/internals/io/writer/). Usually after you've called
[`input()`](https://light.ardi.gg/api/internals/io/input/) already.

```luau
function output<Data>(--Errors--Experimental--Sync--
	writer: DynamicWriter,
	type: Datatype<Data>
): (Data)
```

[Learn More](https://light.ardi.gg/api/internals/io/output/)
]=]
function internal_lib.output<Data>(writer: DynamicWriter, type: Datatype<Data>): Data
	return MISSING_IMPL()
end

--[=[
Allocates a buffer and returns a valid [DynamicWriter](https://light.ardi.gg/api/internals/io/writer/) from a size of
bytes.

```luau
function writer_from_size(--Experimental--Sync--
	bytes: number
): (DynamicWriter)
```

[Learn More](https://light.ardi.gg/api/internals/io/writer/writer_from_size/)
]=]
function internal_lib.writer_from_size(bytes: number): DynamicWriter
	return MISSING_IMPL()
end

--[=[
Returns a valid [DynamicWriter](https://light.ardi.gg/api/internals/io/writer/) from a buffer.

```luau
function writer_from_buff(--Experimental--Sync--
	buff: buffer
): (DynamicWriter)
```

[Learn More](https://light.ardi.gg/api/internals/io/writer/writer_from_buff/)
]=]
function internal_lib.writer_from_buff(buff: buffer): DynamicWriter
	return MISSING_IMPL()
end

--[=[
Returns a buffer from a valid [DynamicWriter](https://light.ardi.gg/api/internals/io/writer/).

```luau
function get_writer_buff(--Experimental--Sync--
    writer: DynamicWriter
): (buffer)
```

[Learn More](https://light.ardi.gg/api/internals/io/writer/get_writer_buff/)
]=]
function internal_lib.get_writer_buff(writer: DynamicWriter): buffer
	return MISSING_IMPL()
end

--[[
Makes sure a valid [DynamicWriter](https://light.ardi.gg/api/internals/io/writer/) has the amount of space specified,
resizing the buffer if necessary.

```luau
function try_realloc(--Experimental--Sync--
    writer: DynamicWriter,
    target_ptr: number
): ()
```

[Learn More](https://light.ardi.gg/api/internals/io/writer/try_realloc/)
]]
function internal_lib.try_realloc(writer: DynamicWriter, target_ptr: number): ()
	return MISSING_IMPL()
end

--[=[
Requires a valid [DynamicWriter](https://light.ardi.gg/api/internals/io/writer/), and a byte ptr.

```luau
function set_byte_ptr(--Experimental--Sync--
    writer: DynamicWriter,
    byte_ptr: number
): ()
```

[Learn More](https://light.ardi.gg/api/internals/io/writer/set_byte_ptr/)
]=]
function internal_lib.set_byte_ptr(writer: DynamicWriter, byte_ptr: number): ()
	return MISSING_IMPL()
end

--[=[
Requires a valid [DynamicWriter](https://light.ardi.gg/api/internals/io/writer/), returns its byte ptr.

```luau
function set_byte_ptr(--Experimental--Sync--
    writer: DynamicWriter
): (number)
```

[Learn More](https://light.ardi.gg/api/internals/io/writer/get_byte_ptr/)
]=]
function internal_lib.get_byte_ptr(writer: DynamicWriter): number
	return MISSING_IMPL()
end

--[=[
Allows you to access the [holy](https://github.com/hardlyardi/holy) serdes "Instance" Light uses.

```luau
function get_holy(--Sync--
): (HolyApi)
```

[Learn More](https://light.ardi.gg/api/internals/get_holy/)
]=]
function internal_lib.get_holy(): HolyApi
	return MISSING_IMPL()
end

return internal_lib
