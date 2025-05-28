local null = require("@light/internal_NULL")

local function recursively_nil_nulls(t: any): any
	if type(t) == "table" then
		local result = {}
		for k, v in t do
			result[k] = recursively_nil_nulls(v)
		end
		return result
	elseif t == null then
		return nil
	else
		return t
	end
end

return recursively_nil_nulls
