local holy = require("../holy")

type Datatype<T = any> = holy.Datatype<T>

local any_datatype = holy.new_datatype(0) :: Datatype<any>

-- TODO

return any_datatype
