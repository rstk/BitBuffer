local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitBuffer = require(ReplicatedStorage.Packages.BitBuffer)

return function(b)
	local buffer = BitBuffer.new()
	local str = string.rep(string.char(math.random(0, 255)), 8)

	for _ = 1, 2^14 / 128 do
		buffer:WriteString(str)
	end
	buffer:ResetCursor()

	b.start()
	for _ = 1, 2^14 / 128 do
		buffer:ReadString()
	end
	b.done()
end