local ReplicatedStorage = game:GetService("ReplicatedStorage")

local light = require(ReplicatedStorage.light).server
local messages = require(ReplicatedStorage.shared.messages)

for _, msg in messages :: any do
	light.connect_sync(msg, function(plr, data)
		light.send(msg, plr, data)
	end)
end

light.begin_replication()
