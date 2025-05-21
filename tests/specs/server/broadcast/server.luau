local message_a = require("./message_a")
local message_ab = require("./message_ab")
local message_b = require("./message_b")
local light = require("@light/lib_main").server
local data_a = require("./data_a")
local data_ab = require("./data_ab")
local data_b = require("./data_b")
local runtest = require("@runtest/")

type TestInterface = runtest.TestInterface

light.begin_replication()

local server = {}

function server.broadcast(client_a: Player, client_b: Player): ()
	light.broadcast(message_a, { client_a }, data_a)
	light.broadcast(message_ab, { client_a, client_b }, data_ab)
	light.broadcast(message_b, { client_b }, data_b)
end

return server
