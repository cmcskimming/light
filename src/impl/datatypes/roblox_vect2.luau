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
--!strict
local datatypes = require("../../include/datatypes/main.h")
local holy = require("../../holy")

type HolyDatatype<T = any> = holy.Datatype<T>

local ty = holy.datatypes
local metadata = holy._datatype_metadata

local cache = {} :: { [HolyDatatype]: HolyDatatype<vector> }
function datatypes.roblox_vect2(coord_datatype: HolyDatatype<number>?): HolyDatatype<vector>
	local coord_datatype = (coord_datatype or ty.f32) :: HolyDatatype

	local cached = cache[coord_datatype]
	if cached ~= nil then return cached end

	if not holy.check_datatype_exists(coord_datatype) then
		error(
			debug.traceback(
				`Invalid vect2: coord must be a valid datatype. Got id: "{coord_datatype}"`
			)
		)
	elseif not metadata.is_number[coord_datatype] then
		error(
			debug.traceback(
				`Invalid vect2: coord must be a number datatype. Got id: "{coord_datatype}"`
			)
		)
	end

	local coord_static_size = metadata.static_size[coord_datatype]
	local coord_des = metadata.des[coord_datatype]

	local vect2_static_size = coord_static_size and coord_static_size * 2

	local roblox_vect2_datatype = holy.new_datatype(vect2_static_size)
	cache[coord_datatype] = roblox_vect2_datatype :: HolyDatatype<vector>

	local roblox_vect2_ser_no_realloc, roblox_vect2_ser_static, roblox_vect2_ser, roblox_vect2_des

	if coord_static_size then
		local coord_ser_static = metadata.ser_static[coord_datatype]

		@native --dynamic_ncgen
		function roblox_vect2_ser_no_realloc(buff: buffer, byte_ptr: number, data: any): number
			coord_ser_static(buff, byte_ptr, data.X)
			byte_ptr += coord_static_size

			coord_ser_static(buff, byte_ptr, data.Y)
			byte_ptr += coord_static_size

			return byte_ptr
		end

		@native --dynamic_ncgen
		function roblox_vect2_ser_static(buff: buffer, byte_ptr: number, data: any): ()
			coord_ser_static(buff, byte_ptr, data.X)
			byte_ptr += coord_static_size

			coord_ser_static(buff, byte_ptr, data.Y)
		end

		@native --dynamic_ncgen
		function roblox_vect2_ser(buff: buffer, byte_ptr: number, data: any): (number, buffer)
			
			--stylua: ignore start
			local len = buffer.len(buff)
			local target_ptr = byte_ptr + vect2_static_size
			if target_ptr > len then local old_buf = buff;len *= 2;while target_ptr > len do len *= 2;end;buff = buffer.create(len);buffer.copy(buff, 0, old_buf, 0, byte_ptr); end
			--stylua: ignore end

			coord_ser_static(buff, byte_ptr, data.X)
			byte_ptr += coord_static_size

			coord_ser_static(buff, byte_ptr, data.Y)

			return target_ptr, buff
		end
	elseif not coord_static_size then
		local coord_ser = metadata.ser[coord_datatype]

		@native --dynamic_ncgen
		function roblox_vect2_ser(buff: buffer, byte_ptr: number, data: any): (number, buffer)
			byte_ptr, buff = coord_ser(buff, byte_ptr, data.X)
			byte_ptr, buff = coord_ser(buff, byte_ptr, data.Y)

			return byte_ptr, buff
		end
	else
		error("unreachable")
	end

	@native --dynamic_ncgen
	function roblox_vect2_des(buff: buffer, byte_ptr: number): (number, any)
		local x, y

		byte_ptr, x = coord_des(buff, byte_ptr)
		byte_ptr, y = coord_des(buff, byte_ptr)

		return byte_ptr, vector.create(x, y)
	end

	metadata.ser_no_realloc[roblox_vect2_datatype] = roblox_vect2_ser_no_realloc
	metadata.ser_static[roblox_vect2_datatype] = roblox_vect2_ser_static
	metadata.ser[roblox_vect2_datatype] = roblox_vect2_ser
	metadata.des[roblox_vect2_datatype] = roblox_vect2_des

	return roblox_vect2_datatype
end

return nil
