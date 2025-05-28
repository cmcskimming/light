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
export type ANY_TABLE = { [any]: any }

local TYPE_OVERHEAD = 1

local BOOLEAN = 1
local F32 = 4
local F64 = 8
local I16 = 2
local I32 = 4
local NIL = 0
local U8 = 1

local AXES = BOOLEAN * 6
local BRICKCOLOR = I32
local CFRAME_CASE_ID = U8
local COLOR3 = F32 * 3
local COLOR3UINT8 = U8 * 3
local COLORSEQUENCEKEYPOINT = F32 * 4
local ENUMITEM = I32
local FACES = BOOLEAN * 6
local INSTANCE = I32
local NUMBER = F64
local NUMBERRANGE = F32 * 2
local NUMBERSEQUENCEKEYPOINT = F32 * 3
local ORIENTATION = I16 * 2
local PHYSICALPROPERTIES = F32 * 5
local RAY = F32 * 6
local UDIM = F32 + I32
local VECTOR2 = F32 * 2
local VECTOR2I16 = I16 * 2
local VECTOR3 = F32 * 3
local VECTOR3I16 = I16 * 3

local RECT = VECTOR2 * 2
local UDIM2 = UDIM * 2

local holy = require("@light/holy")
local packet_size = require("@include/packet_size/main.h")
local roblox = require("@lune/roblox")

type BYTES = number
type OVERHEAD = number

local CFrame = (roblox :: any).CFrame :: typeof(CFrame)
local vlq_size = holy.vlq_size
local is_stfu = holy._is_stfu

--stylua: ignore start
local a = CFrame.Angles :: any
local r = math.rad :: any
local STATIC_SIZE = {
	["nil"] = NIL, Axes = AXES, boolean = BOOLEAN, BrickColor = BRICKCOLOR, Color3 = COLOR3, Color3uint8 = COLOR3UINT8,
	ColorSequenceKeypoint = COLORSEQUENCEKEYPOINT, EnumItem = ENUMITEM, Faces = FACES, Instance = INSTANCE,
	number = NUMBER, NumberRange = NUMBERRANGE, NumberSequenceKeypoint = NUMBERSEQUENCEKEYPOINT,
	PhysicalProperties = PHYSICALPROPERTIES, Ray = RAY, Rect = RECT, UDim = UDIM, UDim2 = UDIM2, Vector2 = VECTOR2,
	Vector2int16 = VECTOR2I16, Vector3 = VECTOR3, Vector3int16 = VECTOR3I16,
}
local CFRAME_SPECIAL_CASES = {
	a(0,0,0),a(0,r(180),r(0)),a(r(90),0,0),a(r(-90),r(-180),r(0)),a(0,r(180),r(180)),a(0,r(0),r(180)),a(r(-90),0,0),
	a(r(90),r(180),r(0)),a(0,r(180),r(90)),a(0,r(0),r(-90)), a(0,r(90),r(90)),a(0,r(-90),r(-90)),a(0,0,r(90)),
	a(0,r(-180),r(-90)),a(0,r(-90),r(90)),a(0,r(90),r(-90)), a(r(-90),r(-90),0),a(r(90),r(90),0), a(0,r(-90),0),
	a(0,r(90),0), a(r(90),r(-90),0), a(r(-90),r(90),0),a(0,r(90),r(180)),a(0,r(-90),r(180))
}
local NUM_CFRAME_SPECIAL_CASE = #CFRAME_SPECIAL_CASES
--stylua: ignore end

packet_size.REMOTE_OVERHEAD = {
	client = 14,
	server = 9,
}

local table_refs = {} :: { [ANY_TABLE]: true? }
function _size(data: any): (number, number)
	local datatype = typeof(data)
	local size: number = STATIC_SIZE[datatype]
	if size then return size, TYPE_OVERHEAD end
	if datatype == "string" then
		local len = #data
		return vlq_size(len) + len, TYPE_OVERHEAD
	elseif datatype == "buffer" then
		local len = buffer.len(data)
		return vlq_size(len) + len, TYPE_OVERHEAD
	elseif datatype == "table" then
		if table_refs[data] then return 1, TYPE_OVERHEAD end
		table_refs[data] = true

		local SIZE = 0
		local OVERHEAD = TYPE_OVERHEAD

		local num_keys = #data
		local dict_eh = if num_keys ~= 0 then next(data, num_keys) else next(data)

		if dict_eh then
			num_keys = 0
			for key, value in data do
				num_keys += 1
				local key_size, key_overhead = _size(key)
				local value_size, value_overhead = _size(value)
				SIZE += key_size + value_size
				OVERHEAD += key_overhead + value_overhead
			end
			SIZE += vlq_size(num_keys)
		else
			for index = 1, num_keys do
				local item_size, item_overhead = _size(data[index])
				SIZE += item_size
				OVERHEAD += item_overhead
			end
			SIZE += vlq_size(num_keys)
		end

		table_refs = {}

		return SIZE, OVERHEAD
	elseif datatype == "CFrame" then
		for specialcase_index = 1, NUM_CFRAME_SPECIAL_CASE do
			local specialcase = CFRAME_SPECIAL_CASES[specialcase_index]
			if data == specialcase then return CFRAME_CASE_ID + VECTOR3, TYPE_OVERHEAD end
		end
		return CFRAME_CASE_ID + VECTOR3 + ORIENTATION, TYPE_OVERHEAD
	elseif (datatype == "NumberSequence") or (datatype == "ColorSequence") then
		-- ?
		-- https://github.com/Pyseph/RemotePacketSizeCounter/blob/873c1b05db4f33f73c74df051cddf9ce875dc8af/src/init.luau#L129
		local SIZE = 4
		for _, keypoint in data.Keypoints do
			SIZE += _size(keypoint)
		end
		return SIZE, TYPE_OVERHEAD
	else
		if not is_stfu() then warn(`Unsupported: "{datatype}"`) end
		-- assume worst-case f64, overestimating is better than underestimating for the purposes of light
		return F64, TYPE_OVERHEAD
	end
end

return {
	size_with_overhead = _size,
}
