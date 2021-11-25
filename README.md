# BitBuffer

Blazing-fast BitBuffer for Roblox.

### Wally

BitBuffer is available on [wally](https://github.com/upliftgames/wally/). Add this to your `wally.toml` and run `wally install`

```toml
[dependencies]
BitBuffer = "rstk/bitbuffer@1.0.0"
```

## Usage

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitBuffer = require(ReplicatedStorage.Packages.BitBuffer)

local PlayerData = {}
PlayerData.__index = PlayerData

function PlayerData.new(serialized: string?)
	local buffer = BitBuffer.FromBase91(serialized or "")

	return setmetatable({
		Money = buffer:ReadUInt(32);
		Experience = buffer:ReadUInt(16);
		AverageFps = buffer:ReadFloat32();
		CustomName = buffer:ReadString();
	}, PlayerData)
end

function PlayerData:Serialize(): string
	local buffer = BitBuffer.new()
	buffer:WriteUInt(32, self.Money)
	buffer:WriteUInt(16, self.Experience)
	buffer:WriteFloat32(self.AverageFps)
	buffer:WriteString(self.CustomName)

	return buffer:ToBase91()
end

export type PlayerData = typeof(PlayerData.new())
return PlayerData
```

## Docs

Documentation can be found [here](https://rstk.github.io/BitBuffer). Keep in mind this is work in progress.

## Minimal tutorial

The available types are:
- UInt
- Int
- Bool
- Char
- Bytes
- String
- Float32
- Float64

You can serialize the buffer into:
- String
- Base64
- Base91 (recommended for DataStores)
- Base128

Using the methods `BitBuffer::ToString()`, `BitBuffer::ToBase64()`, `BitBuffer::ToBase91()` and `BitBuffer::ToBase128()`.  

Create a new BitBuffer with one of the following constructors:
- new
- FromString
- FromBase64
- FromBase91
- FromBase128

Write/Read methods are `buffer:Write<type name>`/`buffer:Read<type name>`.  
For example:
```lua
buffer:WriteUInt(32, 1)
buffer:ReadString()
buffer:WriteBool(true)
```

A BitBuffer has a cursor, indexed in bits, which increases every time something is written/read.
```lua
local buffer = BitBuffer.new() -- The cursor's position is 0
buffer:WriteUInt(16, 1) --> It's now 16
buffer:WriteFloat64() --> It's now 80
buffer:ResetCursor() --> It's now 0
buffer:ReadUInt(16) --> It's now 16
```

A BitBuffer also keeps track of its size.
```lua
local buffer = BitBuffer.new() --> Size is 0
buffer:WriteUInt(32, 80) --> Size is 32
buffer:WriteFloat64() --> Size is 96
buffer:ResetCursor() --> Size is still 96
buffer:ReadUInt(32) --> Size is still 96
buffer:ResetBuffer() --> Size is now 0
```

The rest of the methods are:
```lua
buffer:ResetCursor(): ()
buffer:SetCursor(position: number): ()
buffer:GetCursor(): number
buffer:ResetBuffer(): ()
buffer:GetSize(): number
```
