local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitBuffer = require(ReplicatedStorage.Packages.BitBuffer)

return function()
	local N = script.Parent.TestN.Value

	describe("General tests", function()
		it("Should not throw when reading", function()
			local buffer = BitBuffer.new()
			buffer._buffer = {65 + 2^8*66 + 2^16*67 + 2^24*68}

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
			buffer._buffer = {2^32 - 1}
			buffer._index = 32

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
				buffer._index = 0

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

			buffer._index = 0
			for i = 1, N do
				local str = values[i]
				expect(buffer:ReadString()).to.be.equal(str)
			end
		end)
	end)
end