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
util file for decoupling interface definition and implementation; Allows full cross-runtime compatability when wrapping
runtime-specific code.
]]
local header_types = require("@self/types")
local report = require("./report")

type HeaderIdentity<Implementation = unknown> = header_types.HeaderIdentity<Implementation>

local header_graph = {}
local metatable = { __index = header_graph }

export type GraphIdentity = setmetatable<{
	_next_header: number,
	_unfinalized: { [number]: string? },
}, typeof(metatable)>

local function graph_constructor(): GraphIdentity
	local self = setmetatable({
		_next_header = 0,
		_unfinalized = {},
	}, metatable)

	return self
end

local include_stack = {} :: { number }
local include_stack_top = 0

function header_graph.define<Implementation>(
	self: GraphIdentity,
	header_definition: Implementation
): HeaderIdentity<Implementation>
	local definition_trace = debug.traceback(nil, 2)
	local id = self._next_header
	local unfinalized = self._unfinalized
	local implementations = {} :: { (Implementation) -> () }

	unfinalized[id] = definition_trace

	local function implement(impl_call: (Implementation) -> ()): ()
		if not unfinalized[id] then
			--stylua: ignore
			error(report.bug(report.problem(
				"Header implementation problem; cannot implement after finalized."
					.. ` Definition Trace:\n{definition_trace}`
			)))
		end
		table.insert(implementations, impl_call)
	end

	local function header_include(): Implementation
		for include_stack_pos = include_stack_top, 1, -1 do
			local include_stack_item = include_stack_pos
			if include_stack_item ~= id then continue end
			--stylua: ignore
			error(report.bug(report.problem(
				"Header include problem; recursive include."
					.. ` Definition Trace:\n{definition_trace}`
			)))
		end
		if not unfinalized[id] then return header_definition end

		unfinalized[id] = nil
		local cloned_implementations = table.clone(implementations)
		implementations = {} :: { (Implementation) -> () }

		for index = #cloned_implementations, 1, -1 do
			local implementation_callback = cloned_implementations[index]
			cloned_implementations[index] = nil
			include_stack_top += 1
			include_stack[include_stack_top] = id
			local err_msg, err_trace
			local success = xpcall(implementation_callback, function(err): ()
				err_msg = err
				err_trace = debug.traceback(nil, 2)
			end)
			include_stack[include_stack_top] = nil
			include_stack_top -= 1
			if not success then
				--stylua: ignore
				error(
					`{err_msg}\n{err_trace}\n\n` .. report.bug(report.problem(
						"Header include problem; implementation errored."
						.. ` Definition Trace:\n{definition_trace}`
					))
				)
			end
		end

		return header_definition
	end

	self._next_header += 1
	return {
		implement = implement,
		include = header_include,
	}
end

function header_graph.dead(self: GraphIdentity): index<GraphIdentity, "_unfinalized">
	return table.clone(self._unfinalized)
end

return { graph = graph_constructor }
