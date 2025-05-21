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
local CLIENT_CODE_MODULE = "tests/light_instance/client/main.luau"
local SERVER_CODE_MODULE = "tests/light_instance/server/main.luau"

local _task = require("@test/impl_lune/task/main")

local clients_types = require("@include/clients/types")
local env_require = require("@runtest/env_require")
local filesystem = require("@lune/fs")
local light_instance_types = require("./types")
local luau = require("@lune/luau")
local process = require("@lune/process")
local serdes = require("@lune/serde")

type LightClient = clients_types.Identity
type ClientInterface = light_instance_types.ClientInterface
type ClientLoader = light_instance_types.ClientLoader
type ServerLoader = light_instance_types.ServerLoader
type ServerInterface = light_instance_types.ServerInterface

local client_bytecode: string
local server_bytecode: string

local available_animal_names: { string }

local initialized = false
local function init(): ()
	if initialized then error("already initialized") end
	initialized = true

	local client_code = filesystem.readFile(CLIENT_CODE_MODULE)
	local server_code = filesystem.readFile(SERVER_CODE_MODULE)

	client_bytecode = luau.compile(client_code)
	server_bytecode = luau.compile(server_code)

	local animal_names = filesystem.readFile("tests/light_instance/animal_names.json")
	available_animal_names = serdes.decode("json", animal_names)
end

local all_clients = {} :: { [LightClient]: ClientInterface }

local function new_server_vm(): ServerInterface
	local num_available_names = #available_animal_names

	assert(num_available_names >= 1, "Ran out of available server names")

	local server_name = table.remove(available_animal_names, math.random(1, num_available_names))

	assert(server_name, "Luau")

	local server_loader = luau.load(server_bytecode, {
		debugName = `Server VM "{server_name}`,
		environment = {
			require = env_require.new(process.cwd .. SERVER_CODE_MODULE),
		},
	}) :: () -> ServerLoader

	local server_interface = server_loader():init(server_name)

	return server_interface
end

local new_client_vm
do
	local client_id = 1
	function new_client_vm(): ClientInterface
		local new_client = luau.load(client_bytecode, {
			debugName = `client/main.luau (id: {client_id})`,
			environment = {
				require = env_require.new(process.cwd .. CLIENT_CODE_MODULE),
			},
		}) :: () -> ClientLoader

		local client_interface = new_client():init(client_id)
		all_clients[client_id :: any] = client_interface

		client_id += 1

		return client_interface
	end
end

return {
	init = init,

	new_server_vm = new_server_vm,
	new_client_vm = new_client_vm,
}
