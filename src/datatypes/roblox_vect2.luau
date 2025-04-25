--!nolint LocalShadow
--!strict
local holy = require("../holy")

type Datatype<T = any> = holy.Datatype<T>

local metadata = holy._datatype_metadata

local cache = {} :: { [Datatype]: Datatype<vector> }
local function roblox_vect2(coord_datatype: Datatype<number>?): Datatype<vector>
	local coord_datatype = (coord_datatype or holy.datatypes.f32) :: Datatype

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
	cache[coord_datatype] = roblox_vect2_datatype :: Datatype<vector>

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
		error(debug.traceback("unreachable"))
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

return roblox_vect2
