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
do
end
--[[ ServerFlags
Comprehensive list of server initialization flags for light.
- disable_hook.*
	Disable functionality for security hooks with the fflag system. Should be booleans.

- incoming_reliable_limits.*
	Table of numeric thresholds for a security hook to trigger on incoming reliable events.
	- bitpack_bytes:
		Maximum number of bytes for a single bitpack. Each message gets a bitpack. Number of booleans after decode is
	N * 8. Triggers before decoding.

	- queue_bytes:
		Maximum number of encoded bytes occupied by an entire incoming queue buffer. This can accumulate over multiple
	frames. Decoding takes place the moment you connect to a message. However, if you disconnect while handling queued
	events, some decoded entries which will not contribute to the total number of bytes can stick around until all data
	is processed by a callback.

	- queue_entry_bytes:
		Maximum number of bytes occupied for a single entry which has not been decoded in a message queue. An entry is
	essentially a stream entry which has no been decoded yet.

	- queue_entry_count:
		Maximum count of a combined total of the number of decoded items, as well as entries which have not been decoded
	yet. Triggers before any entries which have not been decoded yet are decoded.

	- stream_bytes:
		Maximum number of total bytes for an incoming stream message batch. Triggers before any deserialization takes
	place.

	- stream_entry_bytes:
		Maximum number of bytes for a single message entry in a stream batch. A message entry includes all of the fires to
	that message that frame on the client, so treat this as a "unique message kinds" limit. Triggers before the message
	entry is deserialized, but not before previous messages are processed and fired.

	- stream_entry_count:
		Maximum number of message entries sent by the client.

- stream_gc:
	Settings for making sure outgoing streams are cleaned up.
	- 
]]
--stylua: ignore
export type ServerFlags = {
	read disable_hook: {
		read error_rqueue_deserializer  : boolean,
		read error_rstream_deserializer : boolean,
		read invalid_rstream_message    : boolean,
		read limit_rbitpack_bytes       : boolean,
		read limit_rqueue_bytes         : boolean,
		read limit_rqueue_entry_bytes   : boolean,
		read limit_rqueue_entry_count   : boolean,
		read limit_rstream_bytes        : boolean,
		read limit_rstream_entry_bytes  : boolean,
		read limit_rstream_entry_count  : boolean,
	},
	read incoming_reliable: {
		read limit: {
			read bitpack_bytes      : number,
			read queue_bytes        : number,
			read queue_entry_bytes  : number,
			read queue_entry_count  : number,
			read stream_bytes       : number,
			read stream_entry_bytes : number,
			read stream_entry_count : number,
		},
	},
}

--[[ ClientFlags
Comprehensive list of client initialization flags for light.
- disable_hook.*
	Disable functionality for security hooks with the fflag system. Should be booleans.

- incoming_reliable_limits
	Table of numeric thresholds for a security hook to trigger on incoming reliable events.
	- bitpack_bytes:
		Maximum number of bytes for a single bitpack. Each message gets a bitpack. Number of booleans after decode is
	N * 8. Triggers before decoding.

	- queue_bytes:
		Maximum number of encoded bytes occupied by an entire incoming queue buffer. This can accumulate over multiple
	frames. Decoding takes place the moment you connect to a message. However, if you disconnect while handling queued
	events, some decoded entries which will not contribute to the total number of bytes can stick around until all data
	is processed by a callback.

	- queue_entry_bytes:
		Maximum number of bytes occupied for a single entry which has not been decoded in a message queue. An entry is
	essentially a stream entry which has no been decoded yet.

	- queue_count:
		Maximum count of entries in an incoming message queue. This is a combined total of the number of decoded items,
	entries which have not been decoded yet. Triggers before any entries which have not been decoded yet are
	decoded.

]]
--stylua: ignore
export type ClientFlags = {
	read disable_hook: {
		read error_rqueue_deserializer  : boolean,
		read error_rstream_deserializer : boolean,
		read limit_rqueue_bytes         : boolean,
		read limit_rqueue_entry_bytes   : boolean,
		read limit_rqueue_entry_count   : boolean,
	},
	read incoming_reliable: {
		read limit: {
			read queue_bytes       : number,
			read queue_entry_bytes : number,
			read queue_entry_count : number,
		},
	},
}

--[[ GlobalFlags
Comprehensive list of global initialization flags which will never be specialized into client / server for light.
- opt_behavior:
	Defines the behavior for optional ser/des.
	- net_kind:
		Can either be "bitpack" - the option will tend toward occupying a single extra bit, or "byte" - the option will
	occupy a single byte.

	- io_kind:
		Can either be "byte" - optionals will be specialcased to occupy a full byte in io, or "none" - optionals will not
	be supported in i/o API.

- bool_behavior:
	Same as opt_behavior, but for booleans.
]]
type GlobalFlags = {
	read opt_behavior: {
		read byte_net: boolean,
	},
	read bool_behavior: {
		read byte_net: boolean,
	},
}

export type ApiIdentity = {
	server: ServerFlags,
	client: ClientFlags,
	global: GlobalFlags,
}

return nil
