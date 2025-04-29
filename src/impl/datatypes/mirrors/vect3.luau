local datatypes = require("../../../include/datatypes/main.h")
local holy = require("../../../holy")

type HolyDatatype<T = any> = holy.Datatype<T>

local ty = holy.datatypes

--[=[
vect3 mirror (coord f32)
]=]
function datatypes.vect3(coord: HolyDatatype<number>?): HolyDatatype<vector>
	return ty.vect3(coord or ty.f32)
end

return nil
