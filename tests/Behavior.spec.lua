local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitBuffer = require(ReplicatedStorage.Packages.BitBuffer)

return function()
	local N = script.Parent.TestN.Value

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

	it("Should override the buffer correctly", function()
		local buffer = BitBuffer.new()
		buffer._buffer = table.create(N, math.pow(2, 32) - 1) -- fill with 1s

		for _ = 1, N do
			buffer:SetCursor(buffer:GetCursor() + 16)
			buffer:WriteUInt(16, 0)
		end
		buffer:ResetCursor()

		for _ = 1, N do
			expect(buffer:ReadUInt(16)).to.be.equal(math.pow(2, 16) - 1)
			expect(buffer:ReadUInt(16)).to.be.equal(0)
		end

		expect(buffer:ReadUInt(32)).to.be.equal(0)
	end)

	it("Should handle size correctly", function()
		local rand = Random.new()
		local buffer = BitBuffer.new(12)

		local expectedSize = 12
		local expectedCursor = 0

		for _ = 1, N do
			local addedSize = rand:NextInteger(6, 18)
			local cursorPosOffset = rand:NextInteger(0, 5)

			buffer:WriteUInt(addedSize, math.pow(2, addedSize) - 1)
			buffer:SetCursor(buffer:GetCursor() - cursorPosOffset)

			expectedCursor += addedSize
			expectedSize = math.max(expectedSize, expectedCursor)
			expectedCursor -= cursorPosOffset

			expect(expectedSize).to.be.equal(buffer:GetSize())
		end
	end)
end