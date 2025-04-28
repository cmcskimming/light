local message_types = require("./types")
local report = require("../report")

-- Totally arbitrary number, just has to be high enough for ser/des IDs not to interfere.
local LOW_MESSAGES_START = 2 ^ 20
local LOW_MESSAGES_END = LOW_MESSAGES_START + 2 ^ 8 - 1
local HIGH_MESSAGES_START = LOW_MESSAGES_END + 1
local HIGH_MESSAGES_END = LOW_MESSAGES_END + 2 ^ 16 - 1

local current_message_id = LOW_MESSAGES_START
local function new_message_id(): message_types.MessageId
	local new = current_message_id

	if new > HIGH_MESSAGES_END then
		error(
			report.problem(
				`Attempted to create a message ID ({new}) which is higher than {HIGH_MESSAGES_END}`
			)
		)
	end

	current_message_id += 1

	return new
end

return {
	new = new_message_id,

	LOW_MESSAGES_START = LOW_MESSAGES_START,
	LOW_MESSAGES_END = LOW_MESSAGES_END,
	HIGH_MESSAGES_START = HIGH_MESSAGES_START,
	HIGH_MESSAGES_END = HIGH_MESSAGES_END,
}
