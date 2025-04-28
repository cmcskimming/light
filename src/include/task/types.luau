export type wait = (seconds: number) -> number

export type spawn = <Arguments..., Returns...>(
	resume: ((Arguments...) -> Returns...) | thread,
	Arguments...
) -> ()

export type defer = <Arguments..., Returns...>(
	func: (Arguments...) -> Returns...,
	Arguments...
) -> ()

export type delay = <Arguments..., Returns...>(
	seconds: number,
	func: (Arguments...) -> Returns...,
	Arguments...
) -> ()

export type close = (thread) -> ()

return nil
