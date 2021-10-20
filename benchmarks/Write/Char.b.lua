local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitBuffer = require(ReplicatedStorage.Packages.BitBuffer)

local char = table.create(256)
for i = 1, 256 do
	char[i] = string.char(i - 1)
end

return function(b)
	local buffer = BitBuffer.new()

	b.start()
	for i = 1, 2^14 do
		buffer:WriteChar(char[i % 256 + 1])
	end
	b.done()
end