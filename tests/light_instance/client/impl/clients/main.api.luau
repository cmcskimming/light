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
local clients = require("@include/clients/main.h")

local client_vm = require("@test/light_instance/client/vm.h").identity
local clients_types = require("@include/clients/types")
local light_instance_types = require("@test/light_instance/types")
local luausignal = require("@light/utils/luau_signal")

type ClientVM = light_instance_types.ClientVM
type Client = clients_types.Identity
type Signal<T...> = luausignal.Identity<T...>

-- TODO: remove this cast
clients.local_client = client_vm :: any

--[[
i can't be asked to implement the rest of this rn its never used on the client
]]

return nil
