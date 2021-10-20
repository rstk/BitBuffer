-- BitBuffer v1.0.0
-- Copyright (c) 2021, rstk
-- All rights reserved.
-- Distributed under the MIT license.
-- https://github.com/rstk/BitBuffer

local Character = table.create(256) do
	for i = 0, 255 do
		Character[i + 1] = string.char(i)
	end
end

type BaseLookup = {To: {[number]: string}, From: {[number]: number}}

local Base64: BaseLookup = {To = nil, From = nil}
do
	local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

	local to = table.create(64)
	local from = {}
	for i = 1, 64 do
		local char = string.sub(alphabet, i, i)
		to[i] = char
		from[string.byte(char)+1] = i-1
	end

	Base64.To = to
	Base64.From = from
end

local Base91: BaseLookup = {To = nil, From = nil}
do
	local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!#$%&()*+,./:;<=>?@[]^_`{|}~'"

	local to = table.create(91)
	local from = {}
	for i = 1, 91 do
		local char = string.sub(alphabet, i, i)
		to[i] = char
		from[string.byte(char)+1] = i-1
	end

	Base91.To = to
	Base91.From = from
end

local function Error(msg: string, ...: any?): ()
	error("[BitBuffer] " .. string.format(msg, ...), 2)
end


local function WriteToBuffer(this: BitBuffer, size: number, value: number): ()
	local buffer = this._buffer
	local index = this._index
	this._index += size

	local bit = index % 32
	local n = bit32.rshift(index, 5) + 1

	if bit + size <= 32 then
		buffer[n] = bit32.replace(buffer[n] or 0, value, bit, size)
	else
		local rem = 32 - bit
		buffer[n] = bit32.replace(buffer[n] or 0, value, bit, rem)
		buffer[n + 1] = bit32.extract(value, rem, size - rem)
	end
end

local function ReadFromBuffer(this: BitBuffer, size: number): number
	local buffer = this._buffer
	local index = this._index
	this._index += size

	local bit = index % 32
	local n = bit32.rshift(index, 5) + 1

	local value = buffer[n] or 0

	if bit == 0 then
		return bit32.extract(value, 0, size)
	elseif bit + size <= 32 then
		return bit32.extract(value, bit, size)
	else
		local rem = 32 - bit
		local nextValue = buffer[n+1] or 0
		return bit32.replace(bit32.extract(value, bit, rem), nextValue, rem, size - rem)
	end
end

local function WriteBytesAligned(this: BitBuffer, bytes: string): ()
	local length = #bytes

	if length < 4 then
		WriteToBuffer(this, length*8, (string.unpack("<I" .. length, bytes)))
	elseif length == 4 then
		local a, b, c, d = string.byte(bytes, 1, 4)
		WriteToBuffer(this, 32, a + b*256 + c*65536 + d*16777216)
	elseif length < 8 then
		local a, b, c, d = string.byte(bytes, 1, 4)
		WriteToBuffer(this, 32, a + b*256 + c*65536 + d*16777216)
		WriteToBuffer(this, length*8 - 32, (string.unpack("<I" .. length - 4, bytes, 5)))
	else
		local buffer = this._buffer
		local index = this._index
		local bit = index % 32
		local n = bit32.rshift(index, 5) + 1
		local offset

		if bit == 0 then
			offset = 0
		else
			offset = 4 - bit/8
			WriteToBuffer(this, 32 - bit, (string.unpack("<I" .. offset, bytes)))
			n += 1
		end

		local last
		for i = offset + 4, length, 4 do
			local a, b, c, d = string.byte(bytes, i-3, i)
			buffer[n] = a + b*256 + c*65536 + d*16777216
			n += 1
			last = i
		end

		local rem = length - last
		if rem > 0 then
			buffer[n] = string.unpack("<I" .. rem, bytes, length-rem+1)
		end

		this._index = (n-1)*32 + rem*8
	end
end

local function ReadBytesAligned(this: BitBuffer, length: number): string
	if length < 4 then
		return string.pack("<I" .. length, ReadFromBuffer(this, length*8))
	elseif length == 4 then
		local value = ReadFromBuffer(this, 32)
		return string.char(
			value % 256,
			bit32.rshift(value, 8) % 256,
			bit32.rshift(value, 16) % 256,
			bit32.rshift(value, 24)
		)
	end

	local prefix = 3 - (this._index/8 - 1) % 4
	local suffix = (length - prefix) % 4
	local t = (length - prefix - suffix) / 4
	local o = 0
	local str = table.create(t + 2)

	if prefix > 0 then
		str[1] = string.pack("<I" .. prefix, ReadFromBuffer(this, prefix * 8))
		o = 1
	end

	local buffer = this._buffer
	local n = bit32.rshift(this._index, 5) + 1
	for i = 1, t do
		local value = buffer[n+i-1] or 0
		str[o+i] = string.char(
			value % 256,
			bit32.rshift(value, 8) % 256,
			bit32.rshift(value, 16) % 256,
			bit32.rshift(value, 24)
		)
	end

	if suffix > 0 then
		str[o + t + 1] = string.pack("<I" .. suffix, bit32.extract(buffer[n + t] or 0, 0, suffix * 8))
	end

	this._index += t*32 + suffix*8
	return table.concat(str)
end

--[=[
	@class BitBuffer

	BitBuffer object.
]=]
local BitBuffer = {ClassName = "BitBuffer"}
BitBuffer.__index = BitBuffer

function BitBuffer:__tostring()
	return "BitBuffer"
end

function BitBuffer.is(obj: any?): boolean
	return getmetatable(obj) == BitBuffer
end

function BitBuffer.new(sizeInBits: number?)
	return setmetatable({
		_buffer = table.create(math.ceil((sizeInBits or 0) / 32));
		_index = 0;
	}, BitBuffer)
end

function BitBuffer.FromString(str: string): BitBuffer
	if type(str) ~= "string" then
		Error("invalid argument #1 to 'FromString' (string expected, got %s)", typeof(str))
	end

	local length = #str
	local buffer = table.create(math.ceil(length/4))
	for i = 1, length / 4 do
		local a, b, c, d = string.byte(str, i*4-3, i*4)
		buffer[i] = a + b*256 + c*65536 + d*16777216
	end

	local rem = length % 4
	if rem ~= 0 then
		buffer[math.ceil(length / 4)] = string.unpack("<I" .. rem, str, length - rem)
	end

	return setmetatable({
		_buffer = buffer;
		_index = 0;
	}, BitBuffer)
end

function BitBuffer.FromBase64(stream: string): BitBuffer
	if type(stream) ~= "string" then
		Error("invalid argument #1 to 'FromBase64' (string expected, got %s)", typeof(stream))
	end

	local length = #stream
	local fromBase64 = Base64.From

	-- decode 4 base64 characters to 24 bits
	local accumulator = 0
	local accIndex = 0

	local chunks = math.floor(length / 4)
	local buffer = table.create(math.ceil((chunks*24 + length%4*6) / 32))
	local bufIndex = 1

	for i = 1, chunks do
		local c0, c1, c2, c3 = string.byte(stream, i*4-3, i*4)
		local v0, v1, v2, v3 = fromBase64[c0+1], fromBase64[c1+1], fromBase64[c2+1], fromBase64[c3+1]

		-- pardon me for this horror
		if v0 == nil then
			Error("invalid argument #1 to 'FromBase64' (invalid Base64 character at position %d)", i)
		elseif v1 == nil then
			Error("invalid argument #1 to 'FromBase64' (invalid Base64 character at position %d)", i + 1)
		elseif v2 == nil then
			Error("invalid argument #1 to 'FromBase64' (invalid Base64 character at position %d)", i + 2)
		elseif v3 == nil then
			Error("invalid argument #1 to 'FromBase64' (invalid Base64 character at position %d)", i + 3)
		end

		local value = v0 + v1*64 + v2*4096 + v3*262144

		if accIndex + 24 <= 32 then
			accumulator = bit32.replace(accumulator, value, accIndex, 24)
			accIndex += 24
		else
			buffer[bufIndex] = accIndex < 32 and bit32.replace(accumulator, value, accIndex, 32 - accIndex) or accumulator
			accumulator = bit32.rshift(value, 32 - accIndex)
			accIndex -= 8
			bufIndex += 1
		end
	end

	for i = chunks*4+1, length do
		local value = fromBase64[string.byte(stream, i, i)+1]

		if accIndex + 6 <= 32 then
			accumulator = bit32.replace(accumulator, value, accIndex, 6)
			accIndex += 6
		else
			buffer[bufIndex] = bit32.replace(accumulator, value, accIndex, 32 - accIndex)
			accumulator = bit32.rshift(value, 32 - accIndex)
			accIndex -= 26 -- += 6 - 32
			bufIndex += 1
		end
	end

	if accIndex ~= 0 then
		buffer[bufIndex] = accumulator
	end

	return setmetatable({
		_buffer = buffer;
		_index = 0;
	}, BitBuffer)
end

function BitBuffer.FromBase91(stream: string): BitBuffer
	if type(stream) ~= "string" then
		Error("invalid argument #1 to 'FromBase91' (string expected, got %s)", typeof(stream))
	elseif #stream % 2 ~= 0 then
		Error("invalid argument #1 to 'FromBase91' (invalid Base91 string; string length must be an even number)")
	end

	local accumulator = 0
	local accIndex = 0
	local buffer = table.create(#stream/2*13/32 + 1)
	local bufIndex = 1

	local fromBase91 = Base91.From

	for i = 1, #stream, 2 do
		local i0, i1 = string.byte(stream, i, i + 1)
		local v0, v1 = fromBase91[i0+1], fromBase91[i1 + 1]

		if v0 == nil then
			Error("invalid argument #1 to 'FromBase91' (invalid Base91 character at position %d)", i)
		elseif v1 == nil then
			Error("invalid argument #1 to 'FromBase91' (invalid Base91 character at position %d)", i + 1)
		end

		local value = v1 * 91 + v0
		local nBits = value % 8192 > 88 and 13 or 14

		if accIndex + nBits <= 32 then
			accumulator = bit32.replace(accumulator, value, accIndex, nBits)
			accIndex += nBits
		else
			local w = 32 - accIndex
			buffer[bufIndex] = w > 0 and bit32.replace(accumulator, value, accIndex, w) or accumulator
			bufIndex += 1
			accumulator = bit32.extract(value, w, nBits - w)
			accIndex = (accIndex + nBits) % 32
		end
	end

	if accIndex ~= 0 then
		buffer[bufIndex] = accumulator
	end

	return setmetatable({
		_buffer = buffer;
		_index = 0;
	}, BitBuffer)
end

function BitBuffer.FromBase128(stream: string): BitBuffer
	if type(stream) ~= "string" then
		Error("invalid argument #1 to 'FromBase128' (string expected, got %s)", typeof(stream))
	end

	local length = #stream
	local buffer = table.create(math.ceil(length / 7) * 7)
	local accumulator = 0
	local bit = 0
	local n = 1

	for i = 1, length do
		local val = string.byte(stream, i)
		if val > 127 then
			Error("invalid argument #1 to 'FromBase128' (invalid Base128 character at position %d: got %d, expected lower than 128)", i, val)
		end

		if bit + 7 <= 32 then
			accumulator += bit32.lshift(val, bit)
			bit += 7
		else
			local rem = 32 - bit
			if rem > 0 then
				buffer[n] = (accumulator + bit32.lshift(val, bit)) % 4294967296
				accumulator = bit32.extract(val, rem, 7 - rem)
				bit -= 25 -- += 7 - 32
			else
				buffer[n] = accumulator
				accumulator = val
				bit = 7
			end

			n += 1
		end
	end

	if bit ~= 0 then
		buffer[n] = accumulator
	end

	return setmetatable({
		_buffer = buffer;
		_index = 0;
	}, BitBuffer)
end

function BitBuffer:ResetCursor(): ()
	self._index = 0
end

function BitBuffer:SetCursor(position: number): ()
	if type(position) ~= "number" then
		Error("invalid argument #1 to 'SetCursor' (number expected, got %s)", typeof(position))
	end

	self._index = math.max(math.floor(position), 0)
end

function BitBuffer:GetCursor(): number
	return self._index
end

function BitBuffer:ResetBuffer(): ()
	table.clear(self._buffer)
	self._index = 0
end


function BitBuffer:ToString(): string
	local bufSize = #self._buffer
	if bufSize == 0 then
		return ""
	end

	local oldIndex = self._index
	self._index = 0
	local str = ReadBytesAligned(self, bufSize * 4)
	self._index = oldIndex
	return str
end

function BitBuffer:ToBase64(): string
	local buffer = self._buffer
	local bufIndex = 2
	local accumulator = buffer[1]
	local accIndex = 0

	local nChunks = math.ceil(#buffer * 32 / 24)
	local output = table.create(nChunks)

	local toBase64 = Base64.To

	for i = 1, nChunks do
		local v
		if accIndex + 24 <= 32 then
			v = bit32.extract(accumulator, accIndex, 24)
			accIndex += 24
		else
			local b = 32 - accIndex
			v = b > 0 and bit32.extract(accumulator, accIndex, b) or 0
			accumulator = buffer[bufIndex] or 0
			bufIndex += 1
			accIndex = 24 - b
			v = bit32.replace(v, accumulator, b, accIndex)
		end

		output[i] =
			toBase64[v % 64 + 1] ..
			toBase64[bit32.rshift(v, 6)  % 64 + 1] ..
			toBase64[bit32.rshift(v, 12) % 64 + 1] ..
			toBase64[bit32.rshift(v, 18) + 1]
	end

	return table.concat(output)
end

function BitBuffer:ToBase91(): string
	local buffer = self._buffer

	local bufIndex = 2
	local accumulator = buffer[1]
	local accIndex = 0
	local output = table.create(32 * #buffer / 13 + 1)
	local outputIndex = 1

	local toBase91Char = Base91.To

	while bufIndex <= #buffer + 1 do
		local v
		if accIndex + 13 <= 32 then
			v = bit32.extract(accumulator, accIndex, 13)
			accIndex += 13
		else
			local b = 32 - accIndex
			local r = accIndex - 19
			v = b > 0 and bit32.extract(accumulator, accIndex, b) or 0
			accumulator = buffer[bufIndex] or 0
			bufIndex += 1
			v = bit32.replace(v, accumulator, b, r)
			accIndex = r
		end

		if v <= 88 then
			if accIndex ~= 32 then
				v += bit32.extract(accumulator, accIndex, 1) * 8192
				accIndex += 1
			else
				accumulator = buffer[bufIndex] or 0
				bufIndex += 1
				v += accumulator % 2 * 8192
				accIndex = 1
			end
		end

		local i0 = v % 91
		local i1 = (v - i0) / 91

		output[outputIndex] = toBase91Char[i0+1] .. toBase91Char[i1+1]
		outputIndex += 1
	end

	return table.concat(output)
end

function BitBuffer:ToBase128(): string
	local buffer = self._buffer
	local b128 = table.create(#buffer)
	local bit = 0

	for i, value in ipairs(buffer) do
		local str = ""
		while bit + 7 <= 32 do
			str ..= Character[bit32.extract(value, bit, 7) + 1]
			bit += 7
		end

		if bit < 32 then
			local rem = 32 - bit
			str ..= Character[bit32.replace(bit32.extract(value, bit, rem), buffer[i+1] or 0, rem, 7 - rem) + 1]
			bit -= 25 -- += 7 - 32
		else
			bit = 0
		end

		b128[i] = str
	end

	return table.concat(b128)
end


function BitBuffer:WriteUInt(bitWidth: number, uint: number): ()
	if type(bitWidth) ~= "number" then
		Error("invalid argument #1 to 'WriteUInt' (number expected, got %s)", typeof(bitWidth))
	elseif bitWidth < 1 or bitWidth > 32 then
		Error("invalid argument #1 to 'WriteUInt' (number must be in range [1,32])")
	elseif type(uint) ~= "number" then
		Error("invalid argument #2 to 'WriteUInt' (number expected, got %s)", typeof(uint))
	end

	WriteToBuffer(self, bitWidth, uint)
end

function BitBuffer:ReadUInt(bitWidth: number): number
	if type(bitWidth) ~= "number" then
		Error("invalid argument #1 to 'ReadUInt' (number expected, got %s)", typeof(bitWidth))
	elseif bitWidth < 1 or bitWidth > 32 then
		Error("invalid argument #1 to 'ReadUInt' (number must be in range [1,32])")
	end

	return ReadFromBuffer(self, bitWidth)
end


function BitBuffer:WriteInt(bitWidth: number, int: number): ()
	if type(bitWidth) ~= "number" then
		Error("invalid argument #1 to 'WriteInt' (number expected, got %s)", typeof(bitWidth))
	elseif bitWidth < 1 or bitWidth > 32 then
		Error("invalid argument #1 to 'WriteInt' (number must be in range [1,32])")
	elseif type(int) ~= "number" then
		Error("invalid argument #2 to 'WriteInt' (number expected, got %s)", typeof(int))
	end

	WriteToBuffer(self, bitWidth, int % (bitWidth == 32 and 4294967296 or bit32.lshift(1, bitWidth)))
end

function BitBuffer:ReadInt(bitWidth: number): number
	if type(bitWidth) ~= "number" then
		Error("invalid argument #1 to 'ReadInt' (number expected, got %s)", typeof(bitWidth))
	elseif bitWidth < 1 or bitWidth > 32 then
		Error("invalid argument #1 to 'ReadInt' (number must be in range [1,32])")
	end

	local value = ReadFromBuffer(self, bitWidth)
	local max = bitWidth == 32 and 4294967296 or bit32.lshift(1, bitWidth)
	return value >= max/2 and value - max or value
end


function BitBuffer:WriteBool(value: any): ()
	if value then
		WriteToBuffer(self, 1, 1)
	else
		WriteToBuffer(self, 1, 0)
	end
end

function BitBuffer:ReadBool(): boolean
	return ReadFromBuffer(self, 1) == 1
end


function BitBuffer:WriteChar(char: string): ()
	if type(char) ~= "string" then
		Error("invalid argument #1 to 'WriteChar' (string expected, got %s)", typeof(char))
	elseif char == "" then
		Error("invalid argument #1 to 'WriteChar' (string cannot be empty)")
	end

	WriteToBuffer(self, 8, string.byte(char, 1, 1))
end

function BitBuffer:ReadChar(): string
	return Character[ReadFromBuffer(self, 8) + 1]
end


function BitBuffer:WriteBytes(bytes: string): ()
	if type(bytes) ~= "string" then
		Error("invalid argument #1 to 'WriteBytes' (string expected, got %s)", typeof(bytes))
	end

	if bytes == "" then
		return
	elseif self._index % 8 == 0 then
		WriteBytesAligned(self, bytes)
	else
		local length = #bytes
		for chunk = 1, length / 4 do
			local index = chunk*4
			local a, b, c, d = string.byte(bytes, index-3, index)
			WriteToBuffer(self, 32, a + b*256 + c*65536 + d*16777216)
		end

		local rem = length % 4
		if rem ~= 0 then
			WriteToBuffer(self, rem * 8, string.unpack("<I" .. rem, bytes, length - rem + 1))
		end
	end
end

function BitBuffer:ReadBytes(length: number): string
	if type(length) ~= "number" then
		Error("invalid argument #1 to 'ReadBytes' (number expected, got %s)", typeof(length))
	end

	if length <= 0 then
		return ""
	elseif self._index % 8 == 0 then
		return ReadBytesAligned(self, length)
	else
		local size = math.floor(length / 4)
		local str = table.create(size + length % 4)
		for i = 1, size do
			local value = ReadFromBuffer(self, 32)

			str[i] = string.char(
				value % 256,
				bit32.rshift(value, 8) % 256,
				bit32.rshift(value, 16) % 256,
				bit32.rshift(value, 24)
			)
		end

		for i = 1, length % 4 do
			str[size + i] = Character[ReadFromBuffer(self, 8) + 1]
		end

		return table.concat(str)
	end
end


function BitBuffer:WriteString(str: string): ()
	if type(str) ~= "string" then
		Error("invalid argument #1 to 'WriteString' (string expected, got %s)", typeof(str))
	end

	local length = #str
	if length > 16777215 then
		Error("invalid argument #1 to 'WriteString' (string length must be lower than 2^24 - 1)")
	end

	WriteToBuffer(self, 24, length)
	self:WriteBytes(str)
end

function BitBuffer:ReadString(): string
	return self:ReadBytes(ReadFromBuffer(self, 24))
end


local POS_INF = math.huge
local NEG_INF = -POS_INF

local BINARY_POS_INF = 0b01111111100000000000000000000000
local BINARY_NEG_INF = 0b11111111100000000000000000000000
local BINARY_NAN = 0b01111111111111111111111111111111

function BitBuffer:WriteFloat32(float: number): ()
	if type(float) ~= "number" then
		Error("invalid argument #1 to 'WriteFloat32' (number expected, got %s)", typeof(float))
	end

	if float == 0 then
		WriteToBuffer(self, 32, 0)
	elseif float == POS_INF then
		WriteToBuffer(self, 32, BINARY_POS_INF)
	elseif float == NEG_INF then
		WriteToBuffer(self, 32, BINARY_NEG_INF)
	elseif float ~= float then
		WriteToBuffer(self, 32, BINARY_NAN)
	else
		local mantissa, exponent = math.frexp(math.abs(float))
		mantissa = math.round((mantissa - 0.5) * 16777216)
		exponent = math.clamp(exponent, -127, 128) + 127
		WriteToBuffer(self, 32, (float >= 0 and 0 or 2147483648) + exponent * 8388608 + mantissa)
	end
end

function BitBuffer:ReadFloat32(): number
	local value = ReadFromBuffer(self, 32)

	if value == 0 then
		return 0
	elseif value == BINARY_POS_INF then
		return POS_INF
	elseif value == BINARY_NEG_INF then
		return NEG_INF
	elseif value == BINARY_NAN then
		return 0/0
	end

	local sign = bit32.band(value, 2147483648) == 0 and 1 or -1
	local exponent = bit32.extract(value, 23, 8) - 127
	local mantissa = value % 8388608
	return sign * (mantissa / 8388608 * 0.5 + 0.5) * 2^exponent
end


function BitBuffer:WriteFloat64(double: number): ()
	if type(double) ~= "number" then
		Error("invalid argument #1 to 'WriteFloat64' (number expected, got %s)", typeof(double))
	end

	local a, b, c, d, e, f, g, h = string.byte(string.pack("<d", double), 1, 8)
	WriteToBuffer(self, 32, a + b*256 + c*65536 + d*16777216)
	WriteToBuffer(self, 32, e + f*256 + g*65536 + h*16777216)
end

function BitBuffer:ReadFloat64(): number
	local a = ReadFromBuffer(self, 32)
	local b = ReadFromBuffer(self, 32)

	return (string.unpack("<d", string.char(
		bit32.band(a, 255),
		bit32.extract(a, 8, 8),
		bit32.extract(a, 16, 8),
		bit32.extract(a, 24, 8),
		bit32.band(b, 255),
		bit32.extract(b, 8, 8),
		bit32.extract(b, 16, 8),
		bit32.extract(b, 24, 8)
	)))
end

export type BitBuffer = typeof(BitBuffer.new())
return BitBuffer
