local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitBuffer = require(ReplicatedStorage.Packages.BitBuffer)

return function()
	local N = script.Parent.TestN.Value

	describe("General tests", function()
		it("Should not throw when reading", function()
			local buffer = BitBuffer.new()
			buffer._buffer = {Random.new():NextInteger(0, math.pow(2, 32) - 1)}

			expect(function()
				buffer:ReadString()
			end).never.to.throw()
		end)

		it("Should not throw when writing", function()
			expect(function()
				BitBuffer.new():WriteString("ABCD")
			end).never.to.throw()
		end)

		it("Should read zeroes when going past the buffer", function()
			local buffer = BitBuffer.new()
			buffer._buffer = {math.pow(2, 32) - 1}
			buffer:SetCursor(32)

			expect(buffer:ReadString()).to.be.equal("")
		end)

		it("Should not throw when writing empty string", function()
			expect(function()
				BitBuffer.new():WriteString("")
			end).never.to.throw()
		end)

		it("Should not throw when reading 0 bytes", function()
			local buffer = BitBuffer.new()

			expect(function()
				buffer:ReadString()
			end).never.to.throw()
		end)

		it("Should override the buffer correctly", function()
			local rand = Random.new()
			local strLens = {}
			local totalBits = 0

			for i = 1, N do
				local len = rand:NextInteger(0, 11)
				strLens[i] = len
				totalBits += 24 + len * 8 + 8
			end


			local buffer = BitBuffer.new()
			buffer._buffer = table.create(math.ceil(totalBits / 32), math.pow(2, 32) - 1)

			-- :WriteString writes 24 bits for the length then 8 bits per bytes
			for i = 1, N do
				local len = strLens[i]
				buffer:WriteString(string.rep("\0", len))
				buffer:SetCursor(buffer:GetCursor() + 8)
			end
			buffer:ResetCursor()

			-- [24]: len, [len*8]: 0, [8]: 2^8-1
			for i = 1, N do
				local realLen = strLens[i]
				local lenInBuffer = buffer:ReadUInt(24)

				expect(lenInBuffer).to.be.equal(realLen)
				expect(buffer:ReadBytes(realLen)).to.be.equal(string.rep("\0", realLen))
				expect(buffer:ReadUInt(8)).to.be.equal(255)
			end
		end)

		it("Should handle size correctly", function()
			local rand = Random.new()
			local buffer = BitBuffer.new(67)

			local expectedSize = 67
			local expectedCursor = 0

			for _ = 1, N do
				local addedSize = rand:NextInteger(4, 13)
				local cursorPosOffset = rand:NextInteger(0, 3)

				buffer:WriteString(string.rep("\255", addedSize))
				buffer:SetCursor(buffer:GetCursor() - cursorPosOffset)

				expectedCursor += addedSize * 8 + 24
				expectedSize = math.max(expectedSize, expectedCursor)
				expectedCursor -= cursorPosOffset

				expect(buffer:GetSize()).to.be.equal(expectedSize)
			end
		end)
	end)

	describe("De/Serializing", function()
		it("Single length", function()
			local rand = Random.new()

			for _ = 1, N do
				local length = rand:NextInteger(1, 32)
				local buffer = BitBuffer.new()

				local str = string.gsub(string.rep("\0", length), "%z", function()
					return string.char(rand:NextInteger(0, 255))
				end)
				buffer:WriteString(str)
				buffer:ResetCursor()

				expect(buffer:ReadString()).to.be.equal(str)
			end
		end)

		it("Random lengths", function()
			local rand = Random.new()
			local values = table.create(N)
			local buffer = BitBuffer.new()

			for i = 1, N do
				local length = rand:NextInteger(1, 16)
				local str = string.gsub(string.rep("\0", length), "%z", function()
					return string.char(rand:NextInteger(0, 255))
				end)
				values[i] = str
				buffer:WriteString(str)
			end

			buffer:ResetCursor()
			for _, str in ipairs(values) do
				expect(buffer:ReadString()).to.be.equal(str)
			end
		end)
	end)
end