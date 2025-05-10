--[[
TODO: stop relying on this file, since luau can inline reused_spawn if open_thread / spawner are defined inline.
]]
local open_thread: thread?

local function runner<Arguments..., Returns...>(func: (Arguments...) -> Returns..., ...: Arguments...): ()
	local closed_thread = open_thread
	open_thread = nil
	func(...)
	open_thread = closed_thread
end

local function spawner<Arguments..., Returns...>(func: (Arguments...) -> Returns..., ...: Arguments...): ()
	local closed_thread = open_thread
	open_thread = nil
	func(...)
	open_thread = closed_thread

	while true do
		runner(coroutine.yield())
	end
end

local function reused_spawn<Arguments..., Returns...>(func: (Arguments...) -> Returns..., ...: Arguments...): ()
	task.spawn(open_thread or spawner, func, ...)
end

return {
	reused_spawn = reused_spawn,
}
