# BitBuffer

Blazing-fast BitBuffer for Roblox.

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
