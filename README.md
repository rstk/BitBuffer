# BitBuffer

Blazing-fast BitBuffer for Roblox.

## Usage

```lua
local PlayerData = {}
PlayerData.__index = PlayerData

function PlayerData.new(serialized: string?)
	local buffer = BitBuffer.FromBase91(serialized or "")

	return setmetatable({
		Money = buffer:ReadUInt(32);
		Experience = buffer:ReadUInt(16);
		CustomName = buffer:ReadString();
	}, PlayerData)
end

function PlayerData:Serialize()
	local buffer = BitBuffer.new()
	buffer:WriteUInt(32, self.Money)
	buffer:WriteUInt(16, self.CurrentLevel)
	buffer:WriteString(self.CustomName)

	return buffer:ToBase91()
end
```
