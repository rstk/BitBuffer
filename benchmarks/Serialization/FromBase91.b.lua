local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitBuffer = require(ReplicatedStorage.Packages.BitBuffer)

local buffer = BitBuffer.new()
for i = 1, 1024 do
	buffer:WriteUInt(32, i)
end
local b91 = buffer:ToBase91()

return function(b)
	b.start()
	BitBuffer.FromBase91(b91)
	b.done()
end