local bitpack = require("../bitpack")
local stream_types = require("./types")

type Bitpacker = bitpack.Identity
type OutgoingStream = stream_types.OutgoingStream

export type ApiIdentity = {
	_current_outgoing: OutgoingStream?,

	_current_bitpack: Bitpacker?,
	_inside_io: boolean?,
}

return {} :: ApiIdentity
