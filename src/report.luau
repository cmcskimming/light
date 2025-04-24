--[=[
General functions for reporting errors / problems.
]=]

local logging_messages = {}

function logging_messages.bug(text: string): string
	return `(BUG, PLEASE REPORT ON THE GITHUB: https://github.com/hardlyardi/light/issues/)\n{text}`
end

function logging_messages.problem(msg: string, trace_level: number?): string
	local level = trace_level and trace_level + 2 or 2

	return debug.traceback(`\n[LIGHT]: {msg}\nERROR TRACE:`, level)
end

function logging_messages.thread(msg: string, thread: thread, trace_level: number?): string
	local level = trace_level and trace_level + 2 or 2

	return debug.traceback(thread, `\n[LIGHT]: {msg}\nTHREAD TRACE:`)
		.. debug.traceback(`\nERROR TRACE:`, level)
end

return logging_messages
