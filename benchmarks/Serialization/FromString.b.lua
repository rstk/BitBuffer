local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitBuffer = require(ReplicatedStorage.Packages.BitBuffer)

local buffer = BitBuffer.new()
for i = 1, 1024 do
	buffer:WriteUInt(32, i)
end
local str = buffer:ToString()

return function(b)
	b.start()
	BitBuffer.FromString(str)
	b.done()
end