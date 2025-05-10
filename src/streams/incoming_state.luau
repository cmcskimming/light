local bitpack = require("../bitpack")

type BitUnpacker = bitpack.UnpackerIdentity

export type ApiIdentity = {
	_current_bitunpacker: BitUnpacker?,
	_current_unknowns: { unknown }?,
	_current_unknown_cursor: number?,

	_inside_io: boolean?,
}

return {} :: ApiIdentity
