local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitBuffer = require(ReplicatedStorage.Packages.BitBuffer)

return function()
	it("Should increase the index when reading", function()
		local buffer = BitBuffer.new()
		buffer:ReadUInt(17)

		expect(buffer._index).to.be.equal(17)
	end)

	it("Should increase the index when writing", function()
		local buffer = BitBuffer.new()
		buffer:WriteUInt(19, 391)

		expect(buffer._index).to.be.equal(19)
	end)

	it("Should return zeroes when reading past the buffer", function()
		local buffer = BitBuffer.new()
		buffer:WriteUInt(32, 2^32 - 1)

		buffer._index = 32 -- don't rely on above behaviors
		expect(buffer:ReadUInt(32)).to.be.equal(0)
	end)
end