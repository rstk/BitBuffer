local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitBuffer = require(ReplicatedStorage.Packages.BitBuffer)

return function(b)
	local buffer = BitBuffer.new()
	for i = 1, 1024 do
		buffer:WriteUInt(32, i)
	end

	b.start()
	buffer:ToBase91()
	b.done()
end