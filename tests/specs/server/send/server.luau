local message = require("./message")
local light = require("@light/lib_main").server
local data = require("./data")
local runtest = require("@runtest/")

type TestInterface = runtest.TestInterface

light.begin_replication()

local server = {}

function server.send(client: Player): ()
	light.send(message, client, data)
end

return server
