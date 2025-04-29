local datatypes = require("../../../include/datatypes/main.h")
local holy = require("../../../holy")

type HolyDatatype<T = any> = holy.Datatype<T>

local ty = holy.datatypes

--[=[
vect2 mirror (coord f32)
]=]
function datatypes.vect2(coord: HolyDatatype<number>?): HolyDatatype<vector>
	return ty.vect2(coord or ty.f32)
end

return nil
