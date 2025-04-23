local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EPSILON = 0.023

local light = require(ReplicatedStorage:WaitForChild("light")).client
local messages = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("messages"))

local function eqtest<T>(msg: T, data: T)
	-- Luau
	local data = data :: any
	local done = false
	light.connect_sync(msg, function(recv: any)
		local eq
		if typeof(recv) == "CFrame" then
			eq = recv:FuzzyEq(data, EPSILON)
		elseif typeof(recv) == "number" then
			eq = math.abs(recv - data) <= EPSILON
		elseif type(recv) == "vector" then
			eq = vector.magnitude(recv - data) <= EPSILON
		else
			eq = recv == data
		end
		if eq then
			print(`test success`)
		else
			done = true
			light.disconnect(msg)
			error(`failure: recieved {recv} expecting {data}`)
		end
		light.disconnect(msg)
		done = true
	end)

	light.send(msg, data)

	repeat
		task.wait()
	until done
end

light.begin_replication()

eqtest(messages.u8, 0)
eqtest(messages.u8, 1)
eqtest(messages.u8, 2 ^ 8 - 1)

eqtest(messages.cframeu16, CFrame.new(1, 2, 3))
eqtest(messages.cframeu16, CFrame.new(2 ^ 16 - 1, 0, 1))
eqtest(messages.cframeu16, CFrame.Angles(0, 0, 0))
eqtest(messages.cframeu16, CFrame.Angles(math.rad(91), 0, 0))
eqtest(messages.cframeu16, CFrame.Angles(0, math.rad(180), math.rad(180)))
eqtest(messages.cframeu16, CFrame.Angles(math.rad(-90), 0, 0))
eqtest(messages.cframeu16, CFrame.Angles(0, math.rad(180), math.rad(90)))
eqtest(messages.cframeu16, CFrame.Angles(0, math.rad(90), math.rad(90)))
eqtest(messages.cframeu16, CFrame.Angles(0, 0, math.rad(90)))
eqtest(messages.cframeu16, CFrame.Angles(0, math.rad(-90), math.rad(90)))
eqtest(messages.cframeu16, CFrame.Angles(math.rad(-90), math.rad(-90), 0))
eqtest(messages.cframeu16, CFrame.Angles(0, math.rad(-90), 0))
eqtest(messages.cframeu16, CFrame.Angles(math.rad(90), math.rad(-90), 0))
eqtest(messages.cframeu16, CFrame.Angles(0, math.rad(90), math.rad(180)))
eqtest(messages.cframeu16, CFrame.Angles(0, math.rad(-90), math.rad(180)))
eqtest(messages.cframeu16, CFrame.Angles(0, math.rad(180), math.rad(0)))
eqtest(messages.cframeu16, CFrame.Angles(math.rad(-90), math.rad(-180), math.rad(0)))
eqtest(messages.cframeu16, CFrame.Angles(0, math.rad(0), math.rad(180)))
eqtest(messages.cframeu16, CFrame.Angles(math.rad(90), math.rad(180), math.rad(0)))
eqtest(messages.cframeu16, CFrame.Angles(0, math.rad(0), math.rad(-90)))
eqtest(messages.cframeu16, CFrame.Angles(0, math.rad(-90), math.rad(-90)))
eqtest(messages.cframeu16, CFrame.Angles(0, math.rad(-180), math.rad(-90)))
eqtest(messages.cframeu16, CFrame.Angles(0, math.rad(90), math.rad(-90)))
eqtest(messages.cframeu16, CFrame.Angles(math.rad(90), math.rad(90), 0))
eqtest(messages.cframeu16, CFrame.Angles(0, math.rad(90), 0))
eqtest(messages.cframeu16, CFrame.Angles(math.rad(-90), math.rad(90), 0))

eqtest(messages.roblox_vect2_u16, Vector2.new(2 ^ 16 - 1, 0))
eqtest(messages.roblox_vect2_u16, Vector2.new(1, 0))

eqtest(messages.bool, true)
eqtest(messages.bool, false)
