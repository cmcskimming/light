local light = require("@light/lib_main").shared

local types = light.datatypes

return light.message("test_msg", {
	foo = { types.any },
	bar = { types.any },
	baz = { types.any },
	bax = types.any,
})
