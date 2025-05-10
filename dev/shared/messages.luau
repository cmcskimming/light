local ReplicatedStorage = game:GetService("ReplicatedStorage")

local light = require(ReplicatedStorage:WaitForChild("light")).shared

local ty = light.datatypes

local messages = {
	foo = { ty.bool },
	bar = { ty.u8 },
	player_connected = ty.instances.Player,
}

local container = light.container(messages)

return container
