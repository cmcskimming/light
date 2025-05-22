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
local env_require = require("@runtest/env_require")
local filesystem = require("@lune/fs")
local luau = require("@lune/luau")
local pretty_print = require("@runtest/utils/pretty_print/main")
local process = require("@lune/process")
local spec_runner_types = require("@runtest/spec/runner/types")
local task = require("@lune/task")
local test_interface = require("@runtest/spec/test/interface")
local test_types = require("@runtest/spec/test/types")

type LoadedSpec = test_types.LoadedSpec
type SpecRunner = spec_runner_types.SpecRunner
type SpecResults = spec_runner_types.Results

local indent_newlines = pretty_print.indent_newlines

local function spec_run_tests(self: SpecRunner): SpecResults
	local spec_path = self._spec_path
	local spec_name = self._spec_name

	local readfile_success, readfile_result = pcall(filesystem.readFile, spec_path)
	if not readfile_success then
		error(
			`Failed to import spec "{spec_name}" from path "{spec_path}". Lune's Filesystem API errored:\n{readfile_result}`,
			2
		)
	end

	local compile_success, compile_result = pcall(luau.compile, readfile_result)
	if not compile_success then
		error(
			`Failed to import spec "{spec_name}" with path "{spec_path}". Luau's compiler errored:\n{compile_result}`,
			2
		)
	end

	local env_require_path = process.cwd .. spec_path

	self.is_initializing = true

	local initialized_spec: LoadedSpec = luau.load(compile_result, {
		debugName = `[SPEC "{spec_name}" (Initialization)]`,
		environment = {
			require = env_require.new(env_require_path),
		},
	})(self)

	self.is_initializing = false

	assert(initialized_spec.kind == "init", "mfw you forgot to call spec.done()?")

	local test_names = initialized_spec.test_names

	local successful_tests = {} :: { [string]: string }
	local failed_tests = {} :: { [string]: string }

	local awaiting = {} :: { thread }

	for _, test_name in test_names do
		self.active_test = test_name

		local identity_spec: LoadedSpec = luau.load(compile_result, {
			debugName = `[SPEC "{spec_name}" (Test "{test_name}")]`,
			environment = {
				require = env_require.new(env_require_path),
			},
		})(self)

		self.active_test = nil

		assert(identity_spec.kind == "test", "what the carp?")

		local definition = identity_spec.definition

		assert(definition, "What the carp!...")
		assert(identity_spec.name == test_name, "what the carp!?")

		local interface = test_interface.new()

		local case_thread = task.spawn(function(): ()
			local case_success, err_msg = xpcall(function()
				definition(interface)
				return nil :: string?
			end, function(err: string)
				return debug.traceback(err, 2)
			end)

			if not case_success then
				interface:fail(indent_newlines(`\nError in test case:\n{err_msg}\n`))
			end
		end)

		interface._break:connect(function(): ()
			interface:fail("\nCase was ended early.")

			task.cancel(case_thread)
		end)

		table.insert(
			awaiting,
			task.spawn(function(): ()
				repeat
					task.wait()
				until coroutine.status(case_thread) == "dead"

				if interface._failed then
					failed_tests[test_name] = interface._output
				else
					successful_tests[test_name] = interface._output
				end
			end)
		)
	end

	while #awaiting ~= 0 do
		for awaiting_index = #awaiting, 1, -1 do
			local thread = awaiting[awaiting_index]

			if coroutine.status(thread) ~= "dead" then continue end

			table.remove(awaiting, awaiting_index)
		end

		task.wait()
	end

	return {
		success = successful_tests,
		failure = failed_tests,
	}
end

local function constructor(path: string, name: string?): SpecRunner
	name = name or `path '{path}'`

	return {
		_spec_path = path,
		_spec_name = name,
		is_initializing = false,
		active_test = nil :: string?,

		test = spec_run_tests,
	}
end

return { new = constructor }
