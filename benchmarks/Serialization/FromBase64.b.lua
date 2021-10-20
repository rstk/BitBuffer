local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitBuffer = require(ReplicatedStorage.Packages.BitBuffer)

local buffer = BitBuffer.new()
for i = 1, 1024 do
	buffer:WriteUInt(32, i)
end
local b64 = buffer:ToBase64()

return function(b)
	b.start()
	BitBuffer.FromBase64(b64)
	b.done()
end