local holy = require("../holy")
local imported_any = require("./any")
local instance_classes = require("./instance_classes")
local report = require("../report")

type Datatype = holy.Datatype

local metadata = holy._datatype_metadata
local instance_is = game and game.IsA

local any_ser_no_realloc = metadata.ser_no_realloc[imported_any]
local any_ser_static = metadata.ser_static[imported_any]
local any_ser = metadata.ser[imported_any]
local any_des = metadata.des[imported_any]
local any_static_size = metadata.static_size[imported_any]

if any_static_size == nil then error(report.bug(report.problem("Could not fetch static size"))) end

return setmetatable({}, {
	__index = function(
		self: any,
		classname: keyof<instance_classes.InstanceClassnameTable>
	): Datatype
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
			error(report.problem(`Unsupported classname: "{classname}"`))
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
}) :: instance_classes.InstanceClassnameTable
