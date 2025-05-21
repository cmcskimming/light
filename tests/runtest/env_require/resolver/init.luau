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
--[[TODO
- Comply Spec
Currently, this resolver does not meet the specification for luau requires (likely for a few reasons), but the most
egregious of which is the inability to correctly resolve ./init.luau/foo or ./init/foo
]]
local MATCH_FILENAME = '[^<>:"/\\|%?%*%.]+'
local ALIAS_PATTERN = `^@({MATCH_FILENAME})`

local filesystem = require("@lune/fs")
local filesystem_path = require("@runtest/utils/filesystem_path")
local resolve_types = require("@self/types")
local serdes = require("@lune/serde")

type LuaurcAliases = resolve_types.LuaurcAliases
type FilesystemPath = filesystem_path.Identity
type ResolvedPath = resolve_types.ResolvedPath

local function get_require_aliases(current_module: FilesystemPath): LuaurcAliases
	local all_aliases: LuaurcAliases = {}

	local filename = current_module:filename()

	if (filename == "init.luau") or (filename == "init.lua") then
		all_aliases["self"] = current_module:navigate(`../`):normalize()
	end

	local navigated_path = current_module

	while navigated_path do
		local luaurc_parent = navigated_path
		local possible_luaurc = luaurc_parent:navigate(".luaurc")
		-- Luau
		navigated_path = navigated_path:parent() :: FilesystemPath?

		local luaurc_kind = possible_luaurc:exists()

		if luaurc_kind ~= "File" then continue end

		local luaurc_content = filesystem.readFile(possible_luaurc:as_str())
		local luaurc_data = serdes.decode("json", luaurc_content)

		local luaurc_aliases = luaurc_data.aliases

		if luaurc_aliases == nil then continue end

		for alias, target in luaurc_aliases do
			if all_aliases[alias] then continue end

			all_aliases[alias] = luaurc_parent:navigate(target):normalize()
		end
	end

	return all_aliases
end

local function lune_typedefs_path_eh(path: FilesystemPath): boolean
	local parent = path:parent()
	if parent == nil then return false end
	local parent_last = parent:get(parent:len())
	if parent_last ~= ".typedefs" then return false end
	local grandparent = parent:parent()
	if grandparent == nil then return false end
	local grandparent_last = grandparent:get(grandparent:len())
	if grandparent_last ~= ".lune" then return false end
	return true
end

local function require_resolver_constructor(
	file_path: FilesystemPath
): (require_path: FilesystemPath) -> ResolvedPath
	local aliases = get_require_aliases(file_path)

	local module_path = assert(file_path:parent(), "needs parent")

	@native
	local function require_resolver(require_path: FilesystemPath): ResolvedPath
		local current_module = module_path

		local first_nav = require_path:get(1)

		if first_nav == nil then
			error(debug.traceback("Failed to resolve require path. Path is empty", 2), -1)
		end

		local alias = first_nav:match(ALIAS_PATTERN)

		if alias then
			local alias_target = aliases[alias]

			if not alias_target then
				--stylua: ignore
				error(debug.traceback(
					`Could not resolve module for "{require_path:as_str()}".`
						.. `Failed to resolve require path. "@{alias}" is not a valid alias defined in .luaurc`,
					2
				), -1)
			end

			if lune_typedefs_path_eh(alias_target) then return { use_lune = true } end

			current_module = alias_target
			require_path = assert(require_path:trim_from_start(), "PATH UTIL BUG")
		elseif not ((first_nav == "..") or (first_nav == ".")) then
			--stylua: ignore
			error(debug.traceback(
				`Could not resolve module for "{require_path:as_str()}".`
					.. ` Paths must begin with either "@<alias>/", "./", or "../"`,
				2
			), -1)
		end

		local resolved: FilesystemPath?

		local resolved_try_root = current_module:merge(require_path) :: FilesystemPath
		local extension = resolved_try_root:extension()

		if extension then
			if (extension ~= "luau") and (extension ~= "lua") then
				--stylua: ignore
				error(debug.traceback(
					`Could not resolve module for "{require_path:as_str()}".`
						.. ` Path has an extension ".{extension}" which is not ".luau" or ".lua"`,
					2
				), -1)
			else
				resolved = resolved_try_root
			end
		end

		local resolved_try = {
			resolved_try_root:navigate("init.luau"),
			resolved_try_root:navigate("init.lua"),
			assert(resolved_try_root:append_to_last(".luau")),
			assert(resolved_try_root:append_to_last(".lua")),
		}

		for _, try in resolved_try do
			local is_file = try:is_file()

			if not is_file then continue end

			if resolved then
				if resolved:equals(try) then
					continue
				else
					--stylua: ignore
					error(debug.traceback(
						`Could not resolve module for "{require_path:as_str()}".`
							.. ` Found multiple matching paths "{resolved:normalize():as_str()}" and "{try:normalize():as_str()}"`,
						2
					), -1)
				end
			end

			resolved = try
		end

		if resolved == nil then
			--stylua: ignore
			error(debug.traceback(
				`Could not resolve module for "{require_path:as_str()}".`
					.. ` Could not find a matching path."`,
				2
			), -1)
		end

		return {
			path = resolved,
			use_lune = false,
		}
	end

	return require_resolver
end

return {
	new = require_resolver_constructor,
}
