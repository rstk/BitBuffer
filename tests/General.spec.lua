local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitBuffer = require(ReplicatedStorage.Packages.BitBuffer)

return function()
	it("ResetCursor", function()
		local buffer = BitBuffer.new()
		buffer:WriteUInt(32, 423 + math.pow(2, 16))
		buffer:ResetCursor()

		expect(buffer._index).to.be.equal(0)
		expect(buffer:ReadUInt(16)).to.be.equal(423)
	end)

	it("SetCursor", function()
		local buffer = BitBuffer.new()
		buffer:WriteUInt(32, 54 + math.pow(2, 16) * 423)
		buffer:SetCursor(16)

		expect(buffer._index).to.be.equal(16)
		expect(buffer:ReadUInt(16)).to.be.equal(423)
	end)

	it("ResetBuffer", function()
		local buffer = BitBuffer.new()
		buffer:WriteUInt(32, math.pow(2, 32) - 1)
		buffer:ResetBuffer()

		expect(buffer:ReadUInt(32)).to.be.equal(0)
	end)
end