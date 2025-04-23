local ReplicatedStorage = game:GetService("ReplicatedStorage")

local light = require(ReplicatedStorage.light).shared

local ty = light.datatypes

local messages = light.container({
	u8 = ty.u8,
	cframeu16 = ty.cframe(ty.u16),
	opt_u8 = ty.optional(ty.u8),
	roblox_vect2_u16 = ty.roblox_vect2(ty.u16),
	bool = ty.bool,
}, "test_namespace")

return messages
