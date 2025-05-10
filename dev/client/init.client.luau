game.Loaded:Wait()
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local light = require(ReplicatedStorage.light).client
local messages = require(ReplicatedStorage.shared.messages)

light.begin_replication()

task.wait(0.5)

local I = true
local O = false

light.send(messages.foo, { O, O, O, O })
light.send(messages.foo, { O, O, O, I })
light.send(messages.foo, { I, O, I, O })

light.connect(messages.foo, function(data: typeof(messages.foo)): ()
	print(data)
end)

light.connect(messages.player_connected, function(data: typeof(messages.player_connected)): ()
	print(data)
end)

light.send(messages.bar, { 1, 25, 255, 0, 10 })
