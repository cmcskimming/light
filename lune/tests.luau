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
local SPEC_DIRECTORY = "tests/specs/"
local MATCH_SPEC_FILE = "%.spec%.luau$"

local files_under_directory = require("@test/utils/files_under_dir")
local process = require("@lune/process")
local runtest = require("@runtest/")

local run = runtest.run
local style = runtest.style

local color = style.color

local blue = color.blue
local green_bright = color.green_bright
local red_bright = color.red_bright

local any_failed = false

for _, filename in files_under_directory(SPEC_DIRECTORY) do
	if not filename:match(MATCH_SPEC_FILE) then continue end
	print(blue(`Running Spec "{filename}"`))

	local num_success = 0
	local num_failed = 0

	local spec = run.spec(`{SPEC_DIRECTORY}{filename}`)
	local results = spec:test()

	for _ in results.success do
		num_success += 1
	end
	for _ in results.failure do
		num_failed += 1
	end

	if num_success > 0 then
		print(green_bright(`{num_success} Tests passed!`))
	else
		print(green_bright(`No tests passed.`))
	end

	if num_failed > 0 then
		any_failed = true
		print(red_bright(`{num_failed} Tests failed!`))
		for name, output in results.failure do
			print(red_bright(`-  "{name}" failed:`) .. `{output}`)
		end
	else
		print(green_bright(`No tests failed.`))
	end
end

if any_failed then process.exit(1) end

process.exit(0)
