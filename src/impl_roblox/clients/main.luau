--[[MIT License Copyright (c) 2025 @hardlyardi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]
--[[
--FOR DESCRIPTIONS OF API & CODE FUNCTION, ETC: https://light.ardi.gg/
--FOR ISSUES, BUG REPORTS, OR FEATURE REQUESTS: https://light.ardi.gg/github
--ROBLOX OSS SERVER: https://discord.com/invite/5KjV64PA3d
--MY DISCORD (please only contact for important questions): https://discord.com/users/331399684415553538/
]]
local Players = game:GetService("Players")

local clients = require("../../include/clients/main.h")

local _context = require("../context/main")
local clients_types = require("../../include/clients/types")
local context = require("../../include/context/main.h")
local luausignal = require("../../utils/luau_signal")

type Client = clients_types.Identity

local a_descendantof_b = game.IsDescendantOf :: (a: Instance, b: Instance) -> boolean
local get_players = Players.GetPlayers

if context.runcontext == "client" then clients.local_client = Players.LocalPlayer end

-- metatable is a slow-path to avoid checking if a player is ingame every time there's a new player
local function __is_connected__index(self: { [Client]: true? }, index: Client): true?
	if a_descendantof_b(index, Players) then
		self[index] = true
		return true
	end
	return nil
end
local is_connected = setmetatable({}, { __index = __is_connected__index }) :: { [Client]: true? }
clients.is_connected = is_connected

local client_added_signal = luausignal() :: luausignal.Identity<Client>
local client_removed_signal = luausignal() :: luausignal.Identity<Client>
clients.client_removed = client_removed_signal
clients.client_added = client_added_signal

--[[
I kinda despise this, but, for once, immediate signalbehavior is our problem-child. You can't use PlayerRemoving because
descendants index isn't updated until after the signal, and, it would lead to leaked players if fallback to __index
returns descendant = true after we've already "Removed" the player. This is almost entirely an edge case that will only
happen if you try to index is_ingame from a PlayerRemoving callback after the internal one. PlayerAdded is replaced with
ChildAdded for consistency with the ChildRemoved pattern
]]
Players.ChildRemoved:Connect(function(plr: Instance): ()
	if not plr:IsA("Player") then return end
	is_connected[plr] = nil
	client_removed_signal:fire(plr)
end)

Players.ChildAdded:Connect(function(plr: Instance): ()
	if not plr:IsA("Player") then return end
	is_connected[plr] = true
	client_added_signal:fire(plr)
end)

function clients.all_clients(): { Client }
	return get_players(Players)
end

return nil
