-- BitBuffer v1.0.0
-- Copyright (c) 2021, rstk
-- All rights reserved.
-- Distributed under the MIT license.
-- https://github.com/rstk/BitBuffer

local Character = table.create(256)
do
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
		from[string.byte(char) + 1] = i - 1
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
		from[string.byte(char) + 1] = i - 1
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

	local bit = index % 32
	local n = bit32.rshift(index, 5) + 1

	if bit + size <= 32 then
		buffer[n] = bit32.replace(buffer[n] or 0, value, bit, size)
	else
		local rem = 32 - bit
		buffer[n] = bit32.replace(buffer[n] or 0, value, bit, rem)
		buffer[n + 1] = bit32.replace(buffer[n + 1] or 0, bit32.extract(value, rem, size - rem), 0, size - rem)
	end

	index += size
	this._size = math.max(this._size, index)
	this._index = index
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
		local nextValue = buffer[n + 1] or 0
		return bit32.replace(bit32.extract(value, bit, rem), nextValue, rem, size - rem)
	end
end

local function WriteBytesAligned(this: BitBuffer, bytes: string): ()
	local length = #bytes

	if length < 4 then
		WriteToBuffer(this, length * 8, (string.unpack("<I" .. length, bytes)))
	elseif length == 4 then
		local a, b, c, d = string.byte(bytes, 1, 4)
		WriteToBuffer(this, 32, a + b * 256 + c * 65536 + d * 16777216)
	elseif length < 8 then
		local a, b, c, d = string.byte(bytes, 1, 4)
		WriteToBuffer(this, 32, a + b * 256 + c * 65536 + d * 16777216)
		WriteToBuffer(this, length * 8 - 32, (string.unpack("<I" .. length - 4, bytes, 5)))
	else
		local buffer = this._buffer
		local index = this._index
		local bit = index % 32
		local n = bit32.rshift(index, 5) + 1
		local offset = 0

		if bit ~= 0 then
			offset = 4 - bit / 8
			WriteToBuffer(this, 32 - bit, (string.unpack("<I" .. offset, bytes)))
			n += 1
		end

		for i = offset + 4, length, 4 do
			local a, b, c, d = string.byte(bytes, i - 3, i)
			buffer[n] = a + b * 256 + c * 65536 + d * 16777216
			n += 1
		end

		local rem = (length - offset - 4) % 4
		if rem > 0 then
			local v = string.unpack("<I" .. rem, bytes, length - rem + 1)
			buffer[n] = bit32.replace(buffer[n] or 0, v, 0, rem * 8)
		end

		index = (n - 1) * 32 + rem * 8
		this._size = math.max(this._size, index)
		this._index = index
	end
end

local function ReadBytesAligned(this: BitBuffer, length: number): string
	if length < 4 then
		return string.pack("<I" .. length, ReadFromBuffer(this, length * 8))
	elseif length == 4 then
		local value = ReadFromBuffer(this, 32)
		return string.char(value % 256, bit32.rshift(value, 8) % 256, bit32.rshift(value, 16) % 256, bit32.rshift(value, 24))
	end

	local prefix = 3 - (this._index / 8 - 1) % 4
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
		local value = buffer[n + i - 1] or 0
		str[o + i] = string.char(value % 256, bit32.rshift(value, 8) % 256, bit32.rshift(value, 16) % 256, bit32.rshift(value, 24))
	end

	if suffix > 0 then
		str[o + t + 1] = string.pack("<I" .. suffix, bit32.extract(buffer[n + t] or 0, 0, suffix * 8))
	end

	this._index += t * 32 + suffix * 8
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

--[=[
	@tag General
	Returns whether the passed object is a BitBuffer.

	```lua
	print(BitBuffer.is(BitBuffer.new())) --> true
	print(BitBuffer.is(true)) --> false
	```

	@param obj any
	@return boolean
]=]
function BitBuffer.is(obj: any): boolean
	return getmetatable(obj :: {}) == BitBuffer
end

--[=[
	@tag Constructor
	Creates a new BitBuffer with an initial size of `sizeInBits`.

	```lua
	local buffer = BitBuffer.new(128)
	print(buffer:GetSize()) --> 128
	```

	@param sizeInBits number? -- Initial size of the buffer in bits (defaults to 0)
	@return BitBuffer
]=]
function BitBuffer.new(sizeInBits: number?)
	sizeInBits = sizeInBits or 0

	return setmetatable({
		_buffer = table.create(math.ceil(sizeInBits :: number / 32));
		_index = 0;
		_size = sizeInBits :: number;
	}, BitBuffer)
end

--[=[
	@tag Constructor
	Creates a new BitBuffer from a binary string, starting with a size corresponding to number of bits in the input string (8 bits per character), and it's cursor positioned at 0.

	```lua
	local buffer = BitBuffer.FromString("\89")
	print(buffer:ReadUInt(8)) --> 89
	print(buffer:GetSize()) --> 8
	```

	See [BitBuffer::ToString](#ToString)
	@param inputStr string
	@return BitBuffer
]=]
function BitBuffer.FromString(inputStr: string): BitBuffer
	if type(inputStr) ~= "string" then
		Error("invalid argument #1 to 'FromString' (string expected, got %s)", typeof(inputStr))
	end

	local length = #inputStr
	local buffer = table.create(math.ceil(length / 4))
	for i = 1, length / 4 do
		local a, b, c, d = string.byte(inputStr, i * 4 - 3, i * 4)
		buffer[i] = a + b * 256 + c * 65536 + d * 16777216
	end

	local rem = length % 4
	if rem ~= 0 then
		buffer[math.ceil(length / 4)] = string.unpack("<I" .. rem, inputStr, length - rem)
	end

	return setmetatable({
		_buffer = buffer;
		_index = 0;
		_size = #inputStr * 8;
	}, BitBuffer)
end

--[=[
	@tag Constructor
	Creates a new BitBuffer from a Base64 string, starting with a size corresponding to the number of bits stored in the input string (6 bits per character), and it's cursor positioned at 0.

	```lua
	local str = base64("\45\180")
	local buffer = BitBuffer.FromBase64(str)

	print(buffer:ReadUInt(8)) --> 45
	print(buffer:ReadUInt(8)) --> 180
	```

	See [BitBuffer::ToBase64](#ToBase64)
	@param inputStr string
	@return BitBuffer
]=]
function BitBuffer.FromBase64(inputStr: string): BitBuffer
	if type(inputStr) ~= "string" then
		Error("invalid argument #1 to 'FromBase64' (string expected, got %s)", typeof(inputStr))
	end

	local length = #inputStr
	local fromBase64 = Base64.From

	-- decode 4 base64 characters to 24 bits
	local accumulator = 0
	local accIndex = 0

	local chunks = math.floor(length / 4)
	local buffer = table.create(math.ceil((chunks * 24 + length % 4 * 6) / 32))
	local bufIndex = 1

	for i = 1, chunks do
		local c0, c1, c2, c3 = string.byte(inputStr, i * 4 - 3, i * 4)
		local v0, v1, v2, v3 = fromBase64[c0 + 1], fromBase64[c1 + 1], fromBase64[c2 + 1], fromBase64[c3 + 1]

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

		local value = v0 + v1 * 64 + v2 * 4096 + v3 * 262144

		if accIndex + 24 <= 32 then
			accumulator = bit32.replace(accumulator, value, accIndex, 24)
			accIndex += 24
		else
			buffer[bufIndex] = if accIndex < 32 then bit32.replace(accumulator, value, accIndex, 32 - accIndex) else accumulator
			accumulator = bit32.rshift(value, 32 - accIndex)
			accIndex -= 8
			bufIndex += 1
		end
	end

	for i = chunks * 4 + 1, length do
		local value = fromBase64[string.byte(inputStr, i, i) + 1]

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
		_size = #inputStr * 6;
	}, BitBuffer)
end

--[=[
	@tag Constructor
	Creates a new BitBuffer from a Base91 string, starting with a size corresponding to the number of bits stored in the input string, and it's cursor positioned at 0.
	**This is the recommended function to use for DataStores.**

	```lua
	local initialBuffer = BitBuffer.new()
	initialBuffer:WriteUInt(32, 78)
	initialBuffer:WriteString("Hi")

	local b91 = initialBuffer:ToBase91()
	local newBuffer = BitBuffer.FromBase91(b91)
	print(newBuffer:ReadUInt(32)) --> 78
	print(newBuffer:ReadString()) --> Hi
	```

	See [BitBuffer::ToBase91](#ToBase91)
	@param inputStr string
	@return BitBuffer

	:::info What is Base91?
	Base91 is a way to pack binary data into text, similar to Base64. It is, on average, about 10% more efficient than Base64. Check [this page](http://base91.sourceforge.net) to learn more.
	:::
]=]
function BitBuffer.FromBase91(inputStr: string): BitBuffer
	if type(inputStr) ~= "string" then
		Error("invalid argument #1 to 'FromBase91' (string expected, got %s)", typeof(inputStr))
	elseif #inputStr % 2 ~= 0 then
		Error("invalid argument #1 to 'FromBase91' (invalid Base91 string: string length must be an even number)")
	end

	local accumulator = 0
	local accIndex = 0
	local buffer = table.create(#inputStr / 2 * 13 / 32 + 1)
	local bufIndex = 1
	local totalBits = 0

	local fromBase91 = Base91.From

	for i = 1, #inputStr, 2 do
		local i0, i1 = string.byte(inputStr, i, i + 1)
		local v0, v1 = fromBase91[i0 + 1], fromBase91[i1 + 1]

		if v0 == nil then
			Error("invalid argument #1 to 'FromBase91' (invalid Base91 character at position %d)", i)
		elseif v1 == nil then
			Error("invalid argument #1 to 'FromBase91' (invalid Base91 character at position %d)", i + 1)
		end

		local value = v1 * 91 + v0
		local nBits = if value % 8192 > 88 then 13 else 14
		totalBits += nBits

		if accIndex + nBits <= 32 then
			accumulator = bit32.replace(accumulator, value, accIndex, nBits)
			accIndex += nBits
		else
			local w = 32 - accIndex
			buffer[bufIndex] = if w > 0 then bit32.replace(accumulator, value, accIndex, w) else accumulator
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
		_size = totalBits;
	}, BitBuffer)
end

--[=[
	@tag Constructor
	Creates a new BitBuffer from a Base128 string, starting with a size corresponding to the number of bits stored in the input string (7 bits per character), and it's cursor positioned at 0.

	```lua
	local str = base128("\255\12")
	local buffer = BitBuffer.FromBase128(str)
	print(buffer:ReadUInt(8)) --> 255
	print(buffer:ReadUInt(8)) --> 12
	```

	See [BitBuffer::ToBase128](#ToBase128)
	@param inputStr string
	@return BitBuffer
]=]
function BitBuffer.FromBase128(inputStr: string): BitBuffer
	if type(inputStr) ~= "string" then
		Error("invalid argument #1 to 'FromBase128' (string expected, got %s)", typeof(inputStr))
	end

	local length = #inputStr
	local buffer = table.create(math.ceil(length / 7) * 7)
	local accumulator = 0
	local bit = 0
	local n = 1

	for i = 1, length do
		local val = string.byte(inputStr, i)
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
		_size = #inputStr * 7;
	}, BitBuffer)
end

--[=[
	@tag General
	Resets the position of the cursor.

	```lua
	local buffer = BitBuffer.new()
	buffer:WriteUInt(32, 890)
	buffer:ResetCursor()

	print(buffer:GetCursor()) --> 0
	```
]=]
function BitBuffer:ResetCursor(): ()
	self._index = 0
end

--[=[
	@tag General
	Sets the position of the cursor to the given position.

	```lua
	local buffer = BitBuffer.new()
	buffer:WriteUInt(32, 67)
	buffer:WriteUInt(32, 44)

	buffer:SetCursor(32)
	print(buffer:ReadUInt(32)) --> 44
	```

	@param position number
]=]
function BitBuffer:SetCursor(position: number): ()
	if type(position) ~= "number" then
		Error("invalid argument #1 to 'SetCursor' (number expected, got %s)", typeof(position))
	end

	self._index = math.max(math.floor(position), 0)
end

--[=[
	@tag General
	Returns the position of the cursor.

	```lua
	local buffer = BitBuffer.new()
	buffer:WriteUInt(17, 901)
	buffer:WriteUInt(4, 2)
	print(buffer:GetCursor()) --> 21
	```

	@return number
]=]
function BitBuffer:GetCursor(): number
	return self._index
end

--[=[
	@tag General
	Clears the buffer, setting its size to zero, and sets its position to 0.

	```lua
	local buffer = BitBuffer.new()
	buffer:WriteUInt(32, math.pow(2, 32) - 1)

	buffer:ResetBuffer()
	print(buffer:GetCursor()) --> 0
	print(buffer:ReadUInt(32)) --> 0
	```
]=]
function BitBuffer:ResetBuffer(): ()
	table.clear(self._buffer)
	self._size = 0
	self._index = 0
end

--[=[
	@tag General
	Returns the size of the buffer.

	```lua
	local buffer = BitBuffer.new()
	buffer:WriteUInt(18, 618)

	print(buffer:GetSize()) --> 18
	```

	@return number
]=]
function BitBuffer:GetSize(): number
	return self._size
end

--[=[
	@tag Serialization
	Serializes the buffer into a binary string.
	You can retrieve the buffer from this string using [BitBuffer.FromString](#FromString).

	```lua
	local buffer = BitBuffer.new()
	buffer:WriteUInt(8, 65)
	buffer:WriteUInt(8, 66)
	buffer:WriteUInt(8, 67)

	print(buffer:ToString()) --> ABC
	```

	See [BitBuffer.FromString](#FromString)
	@return string
]=]
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

--[=[
	@tag Serialization
	Serializes the buffer into a Base64 string.
	You can retrieve the buffer from this string using [BitBuffer.FromBase64](#FromBase64).

	```lua
	local initialBuffer = BitBuffer.new()
	initialBuffer:WriteUInt(15, 919)
	initialBuffer:WriteString("Hello!")

	local b64 = initialBuffer:ToBase64()
	local newBuffer = BitBuffer.FromBase64(b64)
	print(newBuffer:ReadUInt(15)) --> 919
	print(newBuffer:ReadString()) --> Hello!
	```
	See [BitBuffer.FromBase64](#FromBase64)
	@return string
]=]
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
			v = if b > 0 then bit32.extract(accumulator, accIndex, b) else 0
			accumulator = buffer[bufIndex] or 0
			bufIndex += 1
			accIndex = 24 - b
			v = bit32.replace(v, accumulator, b, accIndex)
		end

		output[i] = toBase64[v % 64 + 1]
			.. toBase64[bit32.rshift(v, 6) % 64 + 1]
			.. toBase64[bit32.rshift(v, 12) % 64 + 1]
			.. toBase64[bit32.rshift(v, 18) + 1]
	end

	return table.concat(output)
end

--[=[
	@tag Serialization
	Serializes the buffer into a Base91 string.
	You can retrieve the buffer from this string using [BitBuffer.FromBase91](#FromBase91).
	**This is the recommended function to use for DataStores.**

	```lua
	local buffer = BitBuffer.new()
	buffer:WriteString(playerData.CustomName)
	buffer:WriteUInt(8, playerData.Level)
	buffer:WriteUInt(16, playerData.Money)

	SaveToDataStore(buffer:ToBase91())
	```
	```lua
	local b91 = RetrieveFromDataStore()
	local buffer = BitBuffer.FromBase91(b91)

	local playerData = {
		CustomName = buffer:ReadString();
		Level = buffer:ReadUInt(8);
		Money = buffer:ReadUInt(16);
	}
	```

	See [BitBuffer.FromBase91](#FromBase91)
	@return string
]=]
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
			v = if b > 0 then bit32.extract(accumulator, accIndex, b) else 0
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

		output[outputIndex] = toBase91Char[i0 + 1] .. toBase91Char[i1 + 1]
		outputIndex += 1
	end

	return table.concat(output)
end

--[=[
	@tag Serialization
	Serializes the buffer into a Base128 string.
	You can retrieve the buffer from this string using [BitBuffer.FromBase128](#FromBase128).

	return string
]=]
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
			str ..= Character[bit32.replace(bit32.extract(value, bit, rem), buffer[i + 1] or 0, rem, 7 - rem) + 1]
			bit -= 25 -- += 7 - 32
		else
			bit = 0
		end

		b128[i] = str
	end

	return table.concat(b128)
end

--[=[
	@tag Write
	Writes an unsigned integer of `bitWidth` bits to the buffer.
	`bitWidth` must be an integer between 1 and 32.
	If the input integer uses more bits than `bitWidth`, it will overflow as expected.

	```lua
	buffer:WriteUInt(32, 560) -- Writes 560 to the buffer
	buffer:WriteUInt(3, 9) -- Writes 0b101 (5) because 9 is 0b1101, but `bitWidth` is only 3!
	```

	@param bitWidth number
	@param uint number
]=]
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

--[=[
	@tag Read
	Reads `bitWidth` bits from the buffer as an unsigned integer.
	`bitWidth` must be an integer between 1 and 32.

	```lua
	buffer:WriteUInt(12, 89)
	buffer:ResetCursor()
	print(buffer:ReadUInt(12)) --> 89
	```

	@param bitWidth number
	@return number
]=]
function BitBuffer:ReadUInt(bitWidth: number): number
	if type(bitWidth) ~= "number" then
		Error("invalid argument #1 to 'ReadUInt' (number expected, got %s)", typeof(bitWidth))
	elseif bitWidth < 1 or bitWidth > 32 then
		Error("invalid argument #1 to 'ReadUInt' (number must be in range [1,32])")
	end

	return ReadFromBuffer(self, bitWidth)
end

--[=[
	@tag Write
	Writes a signed integer of `bitWidth` bits using [two's complement](https://en.wikipedia.org/wiki/Two%27s_complement).
	`bitWidth` must be an integer between 1 and 32.
	Overflow is **untested**, use at your own risk.

	```lua
	local buffer = BitBuffer.new()
	buffer:WriteInt(22, -901) --> Writes -901 to the buffer
	```

	@param bitWidth number
	@param int number
]=]
function BitBuffer:WriteInt(bitWidth: number, int: number): ()
	if type(bitWidth) ~= "number" then
		Error("invalid argument #1 to 'WriteInt' (number expected, got %s)", typeof(bitWidth))
	elseif bitWidth < 1 or bitWidth > 32 then
		Error("invalid argument #1 to 'WriteInt' (number must be in range [1,32])")
	elseif type(int) ~= "number" then
		Error("invalid argument #2 to 'WriteInt' (number expected, got %s)", typeof(int))
	end

	WriteToBuffer(self, bitWidth, int % (bit32.lshift(1, bitWidth - 1) * 2))
end

--[=[
	@tag Read
	Reads `bitWidth` bits as a signed integer stored using [two's complement](https://en.wikipedia.org/wiki/Two%27s_complement).
	`bitWidth` must be an integer between 1 and 32.

	```lua
	local buffer = BitBuffer.new()
	buffer:WriteInt(15, -78)
	buffer:ResetCursor()
	print(buffer:ReadInt(15)) --> -78
	```

	@param bitWidth number
	@return number
]=]
function BitBuffer:ReadInt(bitWidth: number): number
	if type(bitWidth) ~= "number" then
		Error("invalid argument #1 to 'ReadInt' (number expected, got %s)", typeof(bitWidth))
	elseif bitWidth < 1 or bitWidth > 32 then
		Error("invalid argument #1 to 'ReadInt' (number must be in range [1,32])")
	end

	local value = ReadFromBuffer(self, bitWidth)
	local max = if bitWidth == 32 then 4294967296 else bit32.lshift(1, bitWidth)
	return if value >= max / 2 then value - max else value
end

--[=[
	@tag Write
	Writes one bit the buffer: 1 if `value` is truthy, 0 otherwise.

	```lua
	local buffer = BitBuffer.new()
	buffer:WriteBool(true) --> Writes 1
	buffer:WriteBool("A") --> Also writes 1
	buffer:WriteBool(nil) --> Writes 0
	```

	@param value any
]=]
function BitBuffer:WriteBool(value: any): ()
	if value then
		WriteToBuffer(self, 1, 1)
	else
		WriteToBuffer(self, 1, 0)
	end
end

--[=[
	@tag Read
	Reads one bit from the buffer and returns a boolean: true if the bit is 1, false if the bit is 0.

	```lua
	local buffer = BitBuffer.new()
	buffer:WriteUInt(4, 0b1011)
	buffer:ResetCursor()

	print(buffer:ReadBool()) --> true
	print(buffer:ReadBool()) --> true
	print(buffer:ReadBool()) --> false
	print(buffer:ReadBool()) --> true
	```

	@return boolean
]=]
function BitBuffer:ReadBool(): boolean
	return ReadFromBuffer(self, 1) == 1
end

--[=[
	@tag Write
	Writes one ASCII character (one byte) to the buffer.
	`char` cannot be an empty string.

	```lua
	local buffer = BitBuffer.new()
	buffer:WriteChar("k")
	buffer:ResetCursor()
	print(buffer:ReadChar()) --> k
	```

	@param char string
]=]
function BitBuffer:WriteChar(char: string): ()
	if type(char) ~= "string" then
		Error("invalid argument #1 to 'WriteChar' (string expected, got %s)", typeof(char))
	elseif char == "" then
		Error("invalid argument #1 to 'WriteChar' (string cannot be empty)")
	end

	WriteToBuffer(self, 8, string.byte(char, 1, 1))
end

--[=[
	@tag Read
	Reads one byte as an ASCII character from the buffer.

	```lua
	local buffer = BitBuffer.new()
	buffer:WriteUInt(8, 65)
	buffer:ResetCursor()
	print(buffer:ReadChar()) --> A
	```

	@return string
]=]
function BitBuffer:ReadChar(): string
	return Character[ReadFromBuffer(self, 8) + 1]
end

--[=[
	@tag Write
	Writes a stream of bytes to the buffer.
	if `bytes` is an empty string, nothing will be written.

	```lua
	local buffer = BitBuffer.new()
	buffer:WriteBytes("AD")
	buffer:ResetCursor()
	print(buffer:ReadUInt(8), buffer:ReadUInt(8)) --> 65 68
	```

	See [BitBuffer::WriteString](#WriteString)
	@param bytes string
]=]
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
			local index = chunk * 4
			local a, b, c, d = string.byte(bytes, index - 3, index)
			WriteToBuffer(self, 32, a + b * 256 + c * 65536 + d * 16777216)
		end

		local rem = length % 4
		if rem ~= 0 then
			WriteToBuffer(self, rem * 8, string.unpack("<I" .. rem, bytes, length - rem + 1))
		end
	end
end

--[=[
	@tag Read
	Reads `length` bytes as a string from the buffer.
	if `length` is 0, nothing will be read and an empty string will be returned.

	```lua
	local buffer = BitBuffer.new()
	buffer:WriteUInt(8, 65)
	buffer:WriteUInt(8, 67)
	print(buffer:ReadBytes(2)) --> AC
	```

	See [BitBuffer::ReadString](#ReadString)
	@param length number
	@return string
]=]
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

			str[i] = string.char(value % 256, bit32.rshift(value, 8) % 256, bit32.rshift(value, 16) % 256, bit32.rshift(value, 24))
		end

		for i = 1, length % 4 do
			str[size + i] = Character[ReadFromBuffer(self, 8) + 1]
		end

		return table.concat(str)
	end
end

--[=[
	@tag Write
	Writes a string to the buffer.

	WriteString will write the length of the string as a 24-bit unsigned integer first, then write the bytes in the string.
	The length of the string cannot be greater than `2^24 - 1 (16777215)`.

	```lua
	local buffer = BitBuffer.new()
	buffer:WriteString("AB")
	buffer:ResetCursor()
	print(buffer:ReadUInt(24), buffer:ReadBytes(2)) --> 2 AB
	```

	See [BitBuffer::WriteBytes](#WriteBytes)
	@param str string
]=]
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

--[=[
	@tag Read
	Reads a string from the buffer (see [BitBuffer::WriteString](#WriteString)).

	```lua
	local buffer = BitBuffer.new()
	buffer:WriteString("Hello!")
	buffer:ResetCursor()
	print(buffer:ReadString()) --> Hello!
	```

	See [BitBuffer:ReadBytes](#ReadBytes)
	@return string
]=]
function BitBuffer:ReadString(): string
	return self:ReadBytes(ReadFromBuffer(self, 24))
end

local POS_INF = math.huge
local NEG_INF = -POS_INF

local BINARY_POS_INF = 0b01111111100000000000000000000000
local BINARY_NEG_INF = 0b11111111100000000000000000000000
local BINARY_NAN = 0b01111111111111111111111111111111

--[=[
	@tag Write
	Writes a single-precision floating point number to the buffer.

	```lua
	local buffer = BitBuffer.new()
	buffer:WriteFloat32(892.738)
	buffer:ResetCursor()
	print(buffer:ReadFloat32()) --> 892.73797607421875
	```

	@param float number
]=]
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
		WriteToBuffer(self, 32, (if float >= 0 then 0 else 2147483648) + exponent * 8388608 + mantissa)
	end
end

--[=[
	@tag Read
	Reads a single-precision floating point number from the buffer.

	```lua
	local buffer = BitBuffer.new()
	buffer:WriteFloat32(892.738)
	buffer:ResetCursor()
	print(buffer:ReadFloat32()) --> 892.73797607421875
	```

	@return number
]=]
function BitBuffer:ReadFloat32(): number
	local value = ReadFromBuffer(self, 32)

	if value == 0 then
		return 0
	elseif value == BINARY_POS_INF then
		return POS_INF
	elseif value == BINARY_NEG_INF then
		return NEG_INF
	elseif value == BINARY_NAN then
		return 0 / 0
	end

	local sign = if bit32.band(value, 2147483648) == 0 then 1 else -1
	local exponent = bit32.extract(value, 23, 8) - 127
	local mantissa = value % 8388608
	return sign * (mantissa / 8388608 * 0.5 + 0.5) * math.pow(2, exponent)
end

--[=[
	@tag Write
	Writes a double-precision floating point number to the buffer.

	```lua
	local buffer = BitBuffer.new()
	buffer:WriteFloat64(-76358128.888202341)
	buffer:ResetCursor()
	print(buffer:ReadFloat64()) --> -76358128.888202
	```

	@param double number
]=]
function BitBuffer:WriteFloat64(double: number): ()
	if type(double) ~= "number" then
		Error("invalid argument #1 to 'WriteFloat64' (number expected, got %s)", typeof(double))
	end

	local a, b, c, d, e, f, g, h = string.byte(string.pack("<d", double), 1, 8)
	WriteToBuffer(self, 32, a + b * 256 + c * 65536 + d * 16777216)
	WriteToBuffer(self, 32, e + f * 256 + g * 65536 + h * 16777216)
end

--[=[
	@tag Read
	Reads a double-precision floating point number from the buffer.

	```lua
	local buffer = BitBuffer.new()
	buffer:WriteFloat64(-76358128.888202341)
	buffer:ResetCursor()
	print(buffer:ReadFloat64()) --> -76358128.888202
	```

	@return number
]=]
function BitBuffer:ReadFloat64(): number
	local a = ReadFromBuffer(self, 32)
	local b = ReadFromBuffer(self, 32)

	return (
			string.unpack(
				"<d",
				string.char(
					bit32.band(a, 255),
					bit32.extract(a, 8, 8),
					bit32.extract(a, 16, 8),
					bit32.extract(a, 24, 8),
					bit32.band(b, 255),
					bit32.extract(b, 8, 8),
					bit32.extract(b, 16, 8),
					bit32.extract(b, 24, 8)
				)
			)
		)
end

export type BitBuffer = typeof(BitBuffer.new())
return BitBuffer
