local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitBuffer = require(ReplicatedStorage.Packages.BitBuffer)

return function()
	local N = script.Parent.TestN.Value

	describe("General tests", function()
		it("Should not throw when reading", function()
			local buffer = BitBuffer.new()
			buffer._buffer = {1}

			expect(function()
				buffer:ReadBool()
			end).never.to.throw()
		end)

		it("Should not throw when writing", function()
			local buffer = BitBuffer.new()

			expect(function()
				buffer:WriteBool(true)
			end).never.to.throw()
		end)

		it("Should read zeroes when going past the buffer", function()
			local buffer = BitBuffer.new()
			buffer._buffer = {math.pow(2, 32) - 1}
			buffer:SetCursor(32)

			expect(buffer:ReadBool()).to.be.equal(false)
		end)
	end)

	describe("De/Serialization", function()
		it("< 32", function()
			local rand = Random.new()
			local buffer = BitBuffer.new()
			local values = table.create(31)

			for i = 1, 31 do
				local boolean = rand:NextNumber() > 0.5
				values[i] = boolean
				buffer:WriteBool(boolean)
			end

			buffer:ResetCursor()
			for _, v in ipairs(values) do
				expect(buffer:ReadBool()).to.be.equal(v)
			end
		end)

		it(">= 32", function()
			local rand = Random.new()
			local buffer = BitBuffer.new()
			local values = table.create(N)

			for i = 1, N do
				local boolean = rand:NextNumber() > 0.5
				values[i] = boolean
				buffer:WriteBool(boolean)
			end

			buffer:ResetCursor()
			for _, v in ipairs(values) do
				expect(buffer:ReadBool()).to.be.equal(v)
			end
		end)
	end)
end