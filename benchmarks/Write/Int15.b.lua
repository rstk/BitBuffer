local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitBuffer = require(ReplicatedStorage.Packages.BitBuffer)

return function(b)
	local buffer = BitBuffer.new()

	b.start()
	for i = 1, 2^14 do
		buffer:WriteInt(15, i - 1)
	end
	b.done()
end