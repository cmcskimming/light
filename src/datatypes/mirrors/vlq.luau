local holy = require("../../holy")

type HolyDatatype<T = any> = holy.Datatype<T>

local ty = holy.datatypes

--[=[
1:1 mirror of vlq (max_bytes 7)
]=]
local function vlq(max_bytes: number?): HolyDatatype<number>
	return ty.vlq(max_bytes or 7)
end

return vlq
