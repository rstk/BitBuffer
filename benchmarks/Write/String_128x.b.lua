local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitBuffer = require(ReplicatedStorage.Packages.BitBuffer)

local bytes = table.create(256)
for i = 1, 256 do
	bytes[i] = string.rep(string.char(i - 1), 128)
end

return function(b)
	local buffer = BitBuffer.new()

	b.start()
	for i = 1, 2^14 / 128 do
		buffer:WriteString(bytes[i % 256 + 1])
	end
	b.done()
end