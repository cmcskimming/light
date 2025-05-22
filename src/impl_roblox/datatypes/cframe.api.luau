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
local U16_BYTES = 2
local I16_BYTES = 2

local datatypes = require("../../include/datatypes/main.h")
local holy = require("../../holy")
local report = require("../../report")

type Datatype<T = any> = holy.Datatype<T>

local _, CFrame__index = xpcall(function(): any
	return (CFrame.identity :: any)[nil]
end, function()
	return debug.info(2, "f")
end)
local to_axis_angle = CFrame.identity.ToAxisAngle
local from_axis_angle = CFrame.fromAxisAngle
local metadata = holy._datatype_metadata

local function sign(n: number): number
	return ((n < 0) and -1) or 1
end

local cache = {} :: { [Datatype]: Datatype<CFrame> }

function datatypes.cframe(position_datatype: Datatype<number>?): Datatype<CFrame>
	local position_datatype = position_datatype or holy.datatypes.f32
	do
		local cached = cache[position_datatype]
		if cached ~= nil then return cached end
	end

	if not holy.check_datatype_exists(position_datatype) then
		error(report.problem(`Invalid CFrame: Datatype of ID "{position_datatype}" does not exist`))
	elseif metadata.is_number[position_datatype] ~= true then
		error(
			report.problem(
				`Invalid CFrame: Expected Datatype of ID "{position_datatype}" to be a number`
			)
		)
	end

	local pos_static_size = metadata.static_size[position_datatype] :: number
	local pos_ser_static = metadata.ser_static[position_datatype]
	local pos_ser = metadata.ser[position_datatype]
	local pos_des = metadata.des[position_datatype]

	local case_pos_static = not not pos_static_size

	local cframe_datatype = holy.new_datatype()

	local cframe_ser_no_realloc, cframe_ser_static, cframe_ser, cframe_des

	if case_pos_static then
		local cframe_static_size = U16_BYTES + I16_BYTES + pos_static_size * 3
		metadata.static_size[cframe_datatype] = cframe_static_size

		@native --dynamic_ncgen
		function cframe_ser_static(buff: buffer, byte_ptr: number, input: any): ()
			local axis, angle = to_axis_angle(input)
			local pos = CFrame__index(input, "Position")

			local z_sign = sign(axis.Z)

			local axis_x = axis.X
			local max_y = (1 - axis_x ^ 2) ^ 0.5

			local mapped_x = math.map(axis_x, -1, 1, 0, 2 ^ 16 - 1) -- u16
			local mapped_y = math.map(axis.Y, -max_y, max_y, 0, 2 ^ 15 - 1) * z_sign

			buffer.writeu16(buff, byte_ptr, mapped_x)
			byte_ptr += U16_BYTES
			buffer.writei16(buff, byte_ptr, mapped_y)
			byte_ptr += I16_BYTES

			local mapped_angle = math.map(angle, 0, math.pi, 0, 2 ^ 16 - 1)

			buffer.writeu16(buff, byte_ptr, mapped_angle)
			byte_ptr += U16_BYTES

			pos_ser_static(buff, byte_ptr, pos.x)
			byte_ptr += pos_static_size
			pos_ser_static(buff, byte_ptr, pos.y)
			byte_ptr += pos_static_size
			pos_ser_static(buff, byte_ptr, pos.z)
			byte_ptr += pos_static_size
		end

		@native --dynamic_ncgen
		function cframe_ser_no_realloc(buff: buffer, byte_ptr: number, input: any): number
			local axis, angle = to_axis_angle(input)
			local pos = CFrame__index(input, "Position")

			local z_sign = sign(axis.Z)

			local axis_x = axis.X
			local max_y = (1 - axis_x ^ 2) ^ 0.5

			local mapped_x = math.map(axis_x, -1, 1, 0, 2 ^ 16 - 1)
			local mapped_y = math.map(axis.Y, -max_y, max_y, 0, 2 ^ 15 - 1) * z_sign

			buffer.writeu16(buff, byte_ptr, mapped_x)
			byte_ptr += U16_BYTES
			buffer.writei16(buff, byte_ptr, mapped_y)
			byte_ptr += I16_BYTES

			local mapped_angle = math.map(angle, 0, math.pi, 0, 2 ^ 16 - 1)

			buffer.writeu16(buff, byte_ptr, mapped_angle)
			byte_ptr += U16_BYTES

			pos_ser_static(buff, byte_ptr, pos.x)
			byte_ptr += pos_static_size
			pos_ser_static(buff, byte_ptr, pos.y)
			byte_ptr += pos_static_size
			pos_ser_static(buff, byte_ptr, pos.z)
			byte_ptr += pos_static_size

			return byte_ptr
		end

		@native --dynamic_ncgen
		function cframe_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
			local axis, angle = to_axis_angle(input)
			local pos = CFrame__index(input, "Position")

			local z_sign = sign(axis.Z)

			local axis_x = axis.X
			local max_y = (1 - axis_x ^ 2) ^ 0.5

			local mapped_x = math.map(axis_x, -1, 1, 0, 2 ^ 16 - 1)
			local mapped_y = math.map(axis.Y, -max_y, max_y, 0, 2 ^ 15 - 1) * z_sign

			--stylua: ignore
			do
				local len = buffer.len(buff)
				local target_ptr = byte_ptr + cframe_static_size
				if target_ptr > len then local old_buf = buff;len *= 2;while target_ptr > len do len *= 2;end;buff = buffer.create(len);buffer.copy(buff, 0, old_buf, 0, byte_ptr); end
			end

			buffer.writeu16(buff, byte_ptr, mapped_x)
			byte_ptr += U16_BYTES
			buffer.writei16(buff, byte_ptr, mapped_y)
			byte_ptr += I16_BYTES

			local mapped_angle = math.map(angle, 0, math.pi, 0, 2 ^ 16 - 1)

			buffer.writeu16(buff, byte_ptr, mapped_angle)
			byte_ptr += U16_BYTES

			pos_ser_static(buff, byte_ptr, pos.x)
			byte_ptr += pos_static_size
			pos_ser_static(buff, byte_ptr, pos.y)
			byte_ptr += pos_static_size
			pos_ser_static(buff, byte_ptr, pos.z)
			byte_ptr += pos_static_size

			return byte_ptr, buff
		end
	else
		@native --dynamic_ncgen
		function cframe_ser(buff: buffer, byte_ptr: number, input: any): (number, buffer)
			local axis, angle = to_axis_angle(input)
			local pos = CFrame__index(input, "Position")

			local z_sign = sign(axis.Z)

			local axis_x = axis.X
			local max_y = (1 - axis_x ^ 2) ^ 0.5

			local mapped_x = math.map(axis_x, -1, 1, 0, 2 ^ 16 - 1)
			local mapped_y = math.map(axis.Y, -max_y, max_y, 0, 2 ^ 15 - 1) * z_sign

			--stylua: ignore
			do
				local len = buffer.len(buff)
				local target_ptr = byte_ptr + U16_BYTES + I16_BYTES
				if target_ptr > len then local old_buf = buff;len *= 2;while target_ptr > len do len *= 2;end;buff = buffer.create(len);buffer.copy(buff, 0, old_buf, 0, byte_ptr); end
			end

			buffer.writeu16(buff, byte_ptr, mapped_x)
			byte_ptr += U16_BYTES
			buffer.writei16(buff, byte_ptr, mapped_y)
			byte_ptr += I16_BYTES

			local mapped_angle = math.map(angle, 0, math.pi, 0, 2 ^ 16 - 1)

			buffer.writeu16(buff, byte_ptr, mapped_angle)
			byte_ptr += U16_BYTES

			byte_ptr, buff = pos_ser(buff, byte_ptr, pos.x)
			byte_ptr, buff = pos_ser(buff, byte_ptr, pos.y)
			byte_ptr, buff = pos_ser(buff, byte_ptr, pos.z)

			return byte_ptr, buff
		end
	end

	@native --dynamic_ncgen
	function cframe_des(buff: buffer, byte_ptr: number): (number, CFrame)
		local mapped_x = buffer.readu16(buff, byte_ptr)
		byte_ptr += U16_BYTES

		local mapped_y = buffer.readi16(buff, byte_ptr)
		byte_ptr += I16_BYTES

		local z_sign = sign(mapped_y)
		mapped_y *= z_sign

		local decoded_x = math.map(mapped_x, 0, 2 ^ 16 - 1, -1, 1)

		local derived_maximum_squared = 1 - decoded_x ^ 2
		local derived_maximum = derived_maximum_squared ^ 0.5

		local decoded_y = math.map(mapped_y, 0, 2 ^ 15 - 1, -derived_maximum, derived_maximum)

		derived_maximum_squared -= decoded_y ^ 2

		local derived_z = (derived_maximum_squared ^ 0.5) * z_sign

		-- Luau
		local axis: any = vector.create(decoded_x, decoded_y, derived_z)

		local mapped_angle = buffer.readu16(buff, byte_ptr)
		byte_ptr += U16_BYTES

		local angle = math.map(mapped_angle, 0, 2 ^ 16 - 1, 0, math.pi)

		local axisangle = from_axis_angle(axis, angle)

		local position_x: number, position_y: number, position_z: number
		byte_ptr, position_x = pos_des(buff, byte_ptr)
		byte_ptr, position_y = pos_des(buff, byte_ptr)
		byte_ptr, position_z = pos_des(buff, byte_ptr)

		-- Luau???
		local position: Vector3 = vector.create(position_x, position_y, position_z) :: any

		local output = axisangle + position

		return byte_ptr, output
	end

	metadata.ser_no_realloc[cframe_datatype] = cframe_ser_no_realloc
	metadata.ser_static[cframe_datatype] = cframe_ser_static
	metadata.ser[cframe_datatype] = cframe_ser
	metadata.des[cframe_datatype] = cframe_des

	return (cframe_datatype :: any) :: Datatype<CFrame>
end

return nil
