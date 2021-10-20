local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitBuffer = require(ReplicatedStorage.Packages.BitBuffer)

local buffer = BitBuffer.new()
for i = 1, 1024 do
	buffer:WriteUInt(32, i)
end
local b128 = buffer:ToBase128()

return function(b)
	b.start()
	BitBuffer.FromBase128(b128)
	b.done()
end