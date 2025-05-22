local message = require("./message")
local light = require("@light/lib_main").client
local data = require("./data")

light.begin_replication()

local function send(): ()
	light.send(message, data)
end

return {
	send = send,
}
