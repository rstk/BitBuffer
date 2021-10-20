local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitBuffer = require(ReplicatedStorage.Packages.BitBuffer)

return function()
	it("ResetCursor", function()
		local buffer = BitBuffer.new()
		buffer:WriteUInt(32, 423 + 2^16)
		buffer:ResetCursor()

		expect(buffer._index).to.be.equal(0)
		expect(buffer:ReadUInt(16)).to.be.equal(423)
	end)

	it("SetCursor", function()
		local buffer = BitBuffer.new()
		buffer:WriteUInt(32, 54 + 2^16 * 423)
		buffer:SetCursor(16)

		expect(buffer._index).to.be.equal(16)
		expect(buffer:ReadUInt(16)).to.be.equal(423)
	end)

	it("GetCursor", function()
		local buffer = BitBuffer.new()
		buffer:WriteUInt(18, 9)

		expect(buffer:GetCursor()).to.be.equal(18)
	end)

	it("ResetBuffer", function()
		local buffer = BitBuffer.new()
		buffer:WriteUInt(32, 0b_00100011_00110010_11101001_10111111)
		buffer:ResetBuffer()

		expect(buffer:ReadUInt(32)).to.be.equal(0)
	end)
end