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
local EXTENSION_PATTERN = `%.([^<>:"/\\|%?%*%.]+)$`
local NULL_CHAR = ""

local filesystem = require("@lune/fs")
local filesystem_path_types = require("@self/types")

type ExistsKind = filesystem_path_types.ExistsKind
type PathNav = filesystem_path_types.PathNav

local function path_to_nav(path: string): PathNav
	local path_only_forward_slashes = path:gsub("[\\]", "/")
	local nav = path_only_forward_slashes:split("/")
	local nav_len = #nav

	for nav_index = nav_len, 1, -1 do
		if nav[nav_index] == NULL_CHAR then table.remove(nav, nav_index) end
	end

	return nav
end

local function nav_to_path(nav: PathNav): string
	local output = (table.concat(nav, "/"))
	print(output)
	return output
end

local filesystem_path = {}
local metatable = { __index = filesystem_path }

export type Identity = setmetatable<{
	_nav: PathNav,
}, typeof(metatable)>

local function internal_constructor(nav: PathNav): Identity
	local self = setmetatable({
		_nav = nav,
	}, metatable)

	return self
end

local function constructor(path: string): Identity
	print(`constructing: {path}`)
	local as_nav = path_to_nav(path)

	return (internal_constructor(as_nav))
end

--[=[
Returns the string at `index` in the path. I.e.,
```luau
local foo = filesystem_path.new("../init.luau")
foo:get(1) --> ".."
foo:get(2) --> "init.luau"
```
]=]
function filesystem_path.get(self: Identity, index: number): string?
	return self._nav[index]
end

function filesystem_path.len(self: Identity): number
	return #self._nav
end

function filesystem_path.as_str(self: Identity): string
	local as_str = nav_to_path(self._nav)

	return as_str
end

function filesystem_path.parent(self: Identity): Identity?
	local cloned_nav = table.clone(self._nav)

	if table.remove(cloned_nav, #cloned_nav) then return (internal_constructor(cloned_nav)) end

	return nil
end

--[=[
removes navigations from the start of the path, optional `amount` will default to 1
]=]
function filesystem_path.trim_from_start(self: Identity, amount: number?): Identity?
	amount = amount or 1

	local nav = self._nav
	local nav_len = #nav

	if amount > nav_len then return nil end

	local output_nav = table.create(nav_len - amount) :: typeof(nav)

	table.move(nav, amount + 1, nav_len, 1, output_nav)

	return (internal_constructor(output_nav))
end

--[=[
Remove relative navigations from the path where possible. I.e.,
```luau
local foo = filesystem_path.new("C:/Users/meow/Documents/../Downloads/")
local bar = filesystem_path.new("./init.luau")
local baz = filesystem_path.new("../meow/./../Documents/")
foo:normalize() --> "C:/Users/meow/Downloads/"
bar:normalize() --> "init.luau"
baz:normalize() --> "../Documents"
```
]=]
function filesystem_path.normalize(self: Identity): Identity
	local nav = table.clone(self._nav)

	local output_nav = {}
	local output_nav_len = 0

	for nav_index = 1, #nav do
		local nav_item = nav[nav_index]

		if nav_item == "." then
			continue
		elseif nav_item == ".." then
			local remove_item = output_nav[output_nav_len]

			if remove_item then
				output_nav[output_nav_len] = nil
				output_nav_len -= 1
				continue
			end
		end

		output_nav_len += 1
		output_nav[output_nav_len] = nav_item
	end

	return (internal_constructor(output_nav))
end

--[=[
returns true if `self:normalized()` and `other:normalized()` have the same navigation items
]=]
function filesystem_path.equals(self: Identity, other: Identity): boolean
	local normalized_a = self:normalize()
	local normalized_b = other:normalize()

	local nav_a = normalized_a._nav
	local nav_b = normalized_b._nav

	local len_a = #nav_a
	local len_b = #nav_b

	if len_a ~= len_b then return false end

	for nav_index = 1, len_a do
		if nav_a[nav_index] ~= nav_b[nav_index] then return false end
	end

	return true
end

--[=[
Append any navigation to the end of the path. I.e.,
```luau
filesystem_path.new("src/test"):append("../meow.luau") --> "src/test/../meow.luau"
```
]=]
function filesystem_path.navigate(self: Identity, navigation_path: string): Identity
	local output_nav = table.clone(self._nav)

	local append_nav = path_to_nav(navigation_path)

	local append_len = #append_nav

	table.move(append_nav, 1, append_len, #output_nav + 1, output_nav)

	return (internal_constructor(output_nav))
end

--[=[
Merge two paths together. I.e.,
```luau
local path_a = filesystem_path.new("src/test")
local path_b = filesystem_path.new("../meow.luau")
path_a:merge(path_b) --> "src/test/../meow.luau"
```
]=]
function filesystem_path.merge(self: Identity, other: Identity): Identity
	local output_nav = table.clone(self._nav)

	local other_nav = other._nav

	local other_len = #other_nav

	table.move(other_nav, 1, other_len, #output_nav + 1, output_nav)

	return (internal_constructor(output_nav))
end

function filesystem_path.append_to_last(self: Identity, append: string): Identity?
	local output_nav = table.clone(self._nav)
	local nav_len = #output_nav

	if nav_len == 0 then return nil end

	local final_item = output_nav[nav_len]

	output_nav[nav_len] = final_item .. append

	return (internal_constructor(output_nav))
end

--[=[
Returns whether the path is a directory. Exclusive with `filesystem_path:is_directory()`
]=]
function filesystem_path.is_file(self: Identity): boolean
	local path_metadata = filesystem.metadata(self:as_str())

	return path_metadata.kind == "file"
end

--[=[
Returns whether the path is a directory. Exclusive with `filesystem_path:is_file()`
]=]
function filesystem_path.is_directory(self: Identity): boolean
	local path_metadata = filesystem.metadata(self:as_str())

	return path_metadata.kind == "dir"
end

--[=[
Returns:
<br>"File" - if the path is a file that exists
<br>"Directory" - if the path is a directory that exists
<br>`nil` - if the path is not a file or directory that exists
]=]
function filesystem_path.exists(self: Identity): ExistsKind?
	local path_metadata = filesystem.metadata(self:as_str())

	local path_kind = path_metadata.kind

	if path_kind == "file" then
		return "File"
	elseif path_kind == "dir" then
		return "Directory"
	end

	return nil
end

--[=[
Gets the name of the file for a path, or returns nil if the path is not a file.
]=]
function filesystem_path.filename(self: Identity, exclude_extension: boolean?): string?
	local is_file = self:is_file()

	if not is_file then return nil end

	local nav = self._nav

	local nav_length = #nav

	local filename: string? = nav[nav_length]

	if filename == nil then return nil end

	if exclude_extension then filename = filename:gsub(EXTENSION_PATTERN, "") end

	return filename
end

--[=[
Returns the extension of the path if it is a file that exists and has an extension.
]=]
function filesystem_path.extension(self: Identity): string?
	local as_str = self:as_str()

	local path_metadata = filesystem.metadata(as_str)
	local path_kind = path_metadata.kind

	if path_kind == "file" then
		local extension = as_str:match(EXTENSION_PATTERN)

		return extension
	end

	return nil
end

return { from_str = constructor }
