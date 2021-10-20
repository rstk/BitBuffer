local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitBuffer = require(ReplicatedStorage.Packages.BitBuffer)

return function()
	local N = script.Parent.TestN.Value

	describe("General tests", function()
		it("Should not throw when reading", function()
			local buffer = BitBuffer.new()
			buffer._buffer = {65 + 2^8*66 + 2^16*67 + 2^24*68}

			expect(function()
				buffer:ReadBytes(4)
			end).never.to.throw()
		end)

		it("Should not throw when writing", function()
			expect(function()
				BitBuffer.new():WriteBytes("ABCD")
			end).never.to.throw()
		end)

		it("Should read zeroes when going past the buffer", function()
			local buffer = BitBuffer.new()
			buffer._buffer = {2^32 - 1}
			buffer._index = 32

			expect(buffer:ReadBytes(4)).to.be.equal("\0\0\0\0")
		end)

		it("Should not throw when writing empty string", function()
			expect(function()
				BitBuffer.new():WriteBytes("")
			end).never.to.throw()
		end)

		it("Should not throw when reading 0 bytes", function()
			local buffer = BitBuffer.new()

			expect(function()
				buffer:ReadBytes(0)
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
				buffer:WriteBytes(str)
				buffer._index = 0

				expect(buffer:ReadBytes(length)).to.be.equal(str)
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
				buffer:WriteBytes(str)
			end

			buffer._index = 0
			for i = 1, N do
				local str = values[i]
				expect(buffer:ReadBytes(#str)).to.be.equal(str)
			end
		end)
	end)
end