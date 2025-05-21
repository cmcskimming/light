local function recursively_remove_userdatas(t: any): any
	if type(t) == "table" then
		local result = {}
		for k, v in t do
			result[k] = recursively_remove_userdatas(v)
		end
		return result
	elseif type(t) == "userdata" then
		return nil
	else
		return t
	end
end

return recursively_remove_userdatas
