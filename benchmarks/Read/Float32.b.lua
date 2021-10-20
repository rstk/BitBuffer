local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitBuffer = require(ReplicatedStorage.Packages.BitBuffer)

return function(b)
	local buffer = BitBuffer.new()

	b.start()
	for _ = 1, 2^14 do
		buffer:ReadFloat32()
	end
	b.done()
end