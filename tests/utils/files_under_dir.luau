--[[
Copyright 2024 ffrostfall

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]
local filesystem = require("@lune/fs")

local function read(directory: string): { string }
	local paths: { string } = {}

	local contents = filesystem.readDir(directory)
	if not contents then return {} end

	for _, filePath in contents do
		if filesystem.isDir(directory .. "/" .. filePath) then
			local subdirectoryContents = read(directory .. "/" .. filePath)

			for _, element in subdirectoryContents do
				table.insert(paths, filePath .. "/" .. element)
			end
		else
			table.insert(paths, filePath)
		end
	end

	return paths
end

return read
