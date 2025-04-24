local holy = require("../holy")
local imported_any = require("./any")
local report = require("../report")

type Datatype<T = any> = holy.Datatype<T>

local metadata = holy._datatype_metadata

local any_ser_no_realloc = metadata.ser_no_realloc[imported_any]
local any_ser_static = metadata.ser_static[imported_any]
local any_ser = metadata.ser[imported_any]
local any_des = metadata.des[imported_any]
local any_static_size = metadata.static_size[imported_any]

if any_static_size == nil then
	error(report.bug(report.problem("Could not fetch static size for any")))
end

local function checked<Input, Checked>(sanity_check: (Input) -> Checked): Datatype<Checked>
	local checked_datatype = holy.new_datatype(any_static_size)

	local function checked_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): number
		input = sanity_check(input)

		return any_ser_no_realloc(buff, byte_ptr, input)
	end

	local function checked_ser_static(buff: buffer, byte_ptr: number, input: any): ()
		input = sanity_check(input)

		return any_ser_static(buff, byte_ptr, input)
	end

	local function checked_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
		input = sanity_check(input)

		return any_ser(buff, byte_ptr, input)
	end

	local function checked_des(buff: buffer, byte_ptr: number): (number, any)
		local output
		byte_ptr, output = any_des(buff, byte_ptr)

		output = sanity_check(output)

		return byte_ptr, output
	end

	metadata.ser_no_realloc[checked_datatype] = checked_ser_no_realloc
	metadata.ser_static[checked_datatype] = checked_ser_static
	metadata.ser[checked_datatype] = checked_ser
	metadata.des[checked_datatype] = checked_des

	return checked_datatype
end

return checked
