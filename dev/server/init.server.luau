local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local light = require(ReplicatedStorage.light).server
local messages = require(ReplicatedStorage.shared.messages)

light.begin_replication()

Players.PlayerAdded:Connect(function(plr): ()
	light.send(messages.foo, plr, { true, true, false, true })
	light.broadcast_to_all(messages.player_connected, plr)
	light.broadcast_to_all_except(messages.player_connected, plr, plr)
end)

light.connect(messages.foo, function(plr, data)
	print(plr, data)
end)

light.connect(messages.bar, function(plr, data)
	print(plr, data)
end)
