local light_instance = require("@test/light_instance/main")
local runtest = require("@runtest/")

type QueriedStreams = typeof(require("@light/streams/server/queried"))

light_instance.init()

local spec = runtest.test.spec.init(...)

local server_vm = light_instance.new_server_vm()
local client_vm_a = light_instance.new_client_vm()
local client_vm_b = light_instance.new_client_vm()
server_vm:connect_client(client_vm_a)
server_vm:connect_client(client_vm_b)

local client_a = client_vm_a.client
local client_b = client_vm_b.client

local queried_streams = server_vm.import("@light/streams/server/queried") :: QueriedStreams

local stream_a = queried_streams.query({ client_a })
local stream_b = queried_streams.query({ client_b })
local stream_ab = queried_streams.query({ client_a, client_b })

spec.test("verify stream locator client sets", function(interface)
	local subscribed_client_sets_by_length = queried_streams.subscribed_client_sets_by_length
	local mapped_locators_by_length = queried_streams.mapped_locators_by_length

	for expected_set_len, subscribed_client_sets in subscribed_client_sets_by_length do
		local locator_maps = mapped_locators_by_length[expected_set_len]
		if not locator_maps then
			interface:fail(
				`\nExpected a stream locator for set length {expected_set_len}, but none was found.`
			)
		end
		for index, set in subscribed_client_sets do
			local set_len = 0
			for _ in set do
				set_len += 1
			end
			if set_len ~= expected_set_len then
				interface:fail(
					`\nexpected set of length {expected_set_len}, got length {set_len}.`
						.. `\nmismatching set: {set}`
				)
			end
			local located = locator_maps[index]
			if not located then
				interface:fail(
					`\nexpected to locate a stream at index {index} of expected length {expected_set_len}`
				)
			end
		end
	end
end)

spec.test("stream locators work", function(interface)
	local locators = queried_streams.mapped_locators_by_length
	local locators_singles = locators[1]
	local locators_doubles = locators[2]

	local client_sets = queried_streams.subscribed_client_sets_by_length
	local client_sets_singles = client_sets[1]
	local client_sets_doubles = client_sets[2]

	if locators_singles == nil then
		interface:fail("\nExpected locator table for client set len 1 to exist")
	end
	if locators_doubles == nil then
		interface:fail("\nExpected locator table for client set len 2 to exist")
	end
	if client_sets_singles == nil then
		interface:fail("\nExpected there to be a list of client sets for length 1")
	end
	if client_sets_doubles == nil then
		interface:fail("\nExpected there to be a list of client sets for length 2")
	end

	do
		local index_a = table.find(locators_singles, stream_a)
		if index_a == nil then
			interface:fail("\nCould not find stream a in locators")
		else
			local client_set = client_sets_singles[index_a]
			local len = 0
			for _ in client_set do
				len += 1
			end
			if len ~= 1 then
				interface:fail(`\nExpected length of found client set for stream(a) to be 1, got {len}`)
			end
			if not client_set[client_a] then
				interface:fail("client set for stream(a) does not match client a")
			end
		end
	end
	do
		local index_b = table.find(locators_singles, stream_b)
		if index_b == nil then
			interface:fail("\nCould not find stream a in locators")
		else
			local client_set = client_sets_singles[index_b]
			local len = 0
			for _ in client_set do
				len += 1
			end
			if len ~= 1 then
				interface:fail(`\nExpected length of found client set for stream(b) to be 1, got {len}`)
			end
			if not client_set[client_b] then
				interface:fail("\nclient set for stream(b) does not match client b")
			end
		end
	end
	do
		local index_ab = table.find(locators_doubles, stream_ab)
		if index_ab == nil then
			interface:fail("\nCould not find stream a in locators")
		else
			local client_set = client_sets_doubles[index_ab]
			local len = 0
			for _ in client_set do
				len += 1
			end
			if len ~= 2 then
				interface:fail(
					`\nExpected length of found client set for stream(a, b) to be 2, got {len}`
				)
			end
			if not client_set[client_a] then
				interface:fail("\nclient set for stream(a, b) does not match client a")
			end
			if not client_set[client_b] then
				interface:fail("\nclient set for stream(a, b) does not match client b")
			end
		end
	end
end)

spec.test("querying for noone returns no stream", function(interface)
	local stream_noone = queried_streams.query({})

	interface:expect_exactly_equal(stream_noone, nil)
end)

spec.test("query(a) generates stream", function(interface): ()
	interface:expect_truthy(stream_a)
end)

spec.test("query(b) generates stream", function(interface)
	interface:expect_truthy(stream_b)
end)

spec.test("query(ab) generates stream", function(interface)
	interface:expect_truthy(stream_ab)
end)

spec.test("(a ~= b)", function(interface)
	interface:expect_not_exactly_equal(stream_a, stream_b)
	interface:expect_not_exactly_equal(stream_a, stream_ab)
end)

spec.test("(a ~= ab)", function(interface)
	interface:expect_not_exactly_equal(stream_a, stream_ab)
end)

spec.test("(b ~= ab)", function(interface)
	interface:expect_not_exactly_equal(stream_b, stream_ab)
end)

return spec.done()
