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
--!nocheck
local datatypes = require("@include/datatypes/main.h")

local _any = require("@light/impl/datatypes/any.api")
local _instance_classes = require("@light/impl/instance_classes/main.api")
local holy = require("@light/holy")
local instance_class_types = require("@include/instance_classes/types")
local instance_classes = require("@include/instance_classes/main.h")
local report = require("@light/report")

type Datatype = holy.Datatype

local metadata = holy._datatype_metadata
local instance_is = game and game.IsA

local any_ser_no_realloc = metadata.ser_no_realloc[datatypes.any]
local any_ser_static = metadata.ser_static[datatypes.any]
local any_ser = metadata.ser[datatypes.any]
local any_des = metadata.des[datatypes.any]
local any_static_size = metadata.static_size[datatypes.any]

if any_static_size == nil then
	error(report.bug(report.problem("Could not fetch static size for any")))
end

datatypes.instances = setmetatable({}, {
	__index = function(self: any, classname: instance_class_types.InstanceClassname): Datatype
		if "SkateboardPlatform" == classname then
			for i = 1, 99 do
				task.defer(error, "❌❌❌ LIGHT DOES NOT SUPPORT SKATEBOARD PLATFORM")
			end
			return error("❌❌❌ LIGHT DOES NOT SUPPORT SKATEBOARD PLATFORM")
		elseif "WireframeHandleAdornment" == classname then
			for i = 1, 99 do
				task.defer(error, "❌❌❌ LIGHT DOES NOT SUPPORT WIREFRAME HANDLE ADORNMENT")
			end
			return error("❌❌❌ LIGHT DOES NOT SUPPORT WIREFRAME HANDLE ADORNMENT")
		elseif not instance_classes[classname] then
			error(report.problem(`Unsupported classname: "{classname}"\nDid you spell it correctly?`))
		end

		local inst_datatype = holy.new_datatype(any_static_size)
		self[classname] = inst_datatype

		local function incorrect_class_err(input_classname: string): any
			error(
				report.problem(`Expected instance with class "{classname}", got "{input_classname}"`, 1)
			)
		end

		local function instance_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): number
			if instance_is(input, classname) == false then
				return incorrect_class_err(input.ClassName)
			end
			return any_ser_no_realloc(buff, byte_ptr, input)
		end

		local function instance_ser_static(buff: buffer, byte_ptr: number, input: any): ()
			if instance_is(input, classname) == false then
				return incorrect_class_err(input.ClassName)
			end
			return any_ser_static(buff, byte_ptr, input)
		end

		local function instance_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
			if instance_is(input, classname) == false then
				return incorrect_class_err(input.ClassName)
			end
			return any_ser(buff, byte_ptr, input)
		end

		local function instance_des(buff: buffer, byte_ptr: number): (number, any)
			local output
			byte_ptr, output = any_des(buff, byte_ptr)
			if instance_is(output, classname) == false then
				return incorrect_class_err(output.ClassName)
			end
			return byte_ptr, output
		end

		metadata.ser_no_realloc[inst_datatype] = instance_ser_no_realloc
		metadata.ser_static[inst_datatype] = instance_ser_static
		metadata.ser[inst_datatype] = instance_ser
		metadata.des[inst_datatype] = instance_des

		return inst_datatype
	end,
}) :: any

return nil
