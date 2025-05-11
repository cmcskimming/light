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
--!nolint LocalShadow
--!optimize 2
local IMPL = nil :: any

local _context = require("../context/main")
local context = require("../../include/context/main.h")
local instance_classes = require("../../instance_classes")
local report = require("../../report")

export type InstanceStorageClass = Folder

local INSTANCE_STORAGE_CLASSNAME = "Folder"
local INSTANCE_STORAGE_PARENT = game:GetService("ReplicatedStorage")
local INSTANCE_STORAGE_NAME = "__LIGHT_STORAGE_"

local roblox_storage = {
	inst = IMPL :: InstanceStorageClass,
}

export type ApiIdentity = typeof(roblox_storage)

function roblox_storage.init(): ()
	if context.runcontext == "server" then
		local new_storage = Instance.new(INSTANCE_STORAGE_CLASSNAME)
		new_storage.Name = INSTANCE_STORAGE_NAME

		new_storage.Parent = INSTANCE_STORAGE_PARENT

		roblox_storage.inst = new_storage :: InstanceStorageClass
	elseif context.runcontext == "client" then
		local found_storage = INSTANCE_STORAGE_PARENT:WaitForChild(INSTANCE_STORAGE_NAME)

		roblox_storage.inst = found_storage :: InstanceStorageClass
	end
end

function roblox_storage.client_fetch(
	self: ApiIdentity,
	name: string,
	classname: instance_classes.InstanceClassname
): Instance
	if not instance_classes[classname] then
		error(report.problem(`Expected a valid Instance classname, got "{classname}"`))
	end

	local found = self.inst:WaitForChild(name)

	if found:IsA(classname) then return found end

	error(
		report.problem(
			`Expected stored instance of name "{name}" to belong to class "{classname}", got class {found.ClassName}`
		)
	)
end

function roblox_storage.server_make(
	self: ApiIdentity,
	name: string,
	classname: instance_classes.InstanceClassname,
	parent: boolean?
): Instance
	local created = Instance.new(classname)

	created.Name = name

	if parent then created.Parent = self.inst end

	return created
end

return roblox_storage
