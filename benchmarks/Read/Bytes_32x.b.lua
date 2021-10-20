local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitBuffer = require(ReplicatedStorage.Packages.BitBuffer)

return function(b)
	local buffer = BitBuffer.new()

	b.start()
	for _ = 1, 2^14 / 128 do
		buffer:ReadBytes(32)
	end
	b.done()
end