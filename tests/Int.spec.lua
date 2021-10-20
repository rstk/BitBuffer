local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitBuffer = require(ReplicatedStorage.Packages.BitBuffer)

local function sums(n)
	return (n*n + n) / 2
end

return function()
	local N = script.Parent.TestN.Value

	describe("General tests", function()
		it("Should not throw when writing", function()
			local rand = Random.new()

			for bw = 1, 32 do
				expect(function()
					BitBuffer.new(bw):WriteInt(bw, rand:NextInteger(-2^(bw - 1), 2^(bw - 1) - 1))
				end).never.to.throw()
			end
		end)

		it("Should not throw when reading", function()
			for bw = 1, 32 do
				local buffer = BitBuffer.new()
				buffer._buffer = {Random.new():NextInteger(-2^(bw - 1), 2^(bw - 1) - 1)}

				expect(function()
					buffer:ReadInt(bw)
				end).never.to.throw()
			end
		end)

		it("Should read zeroes when going past the buffer", function()
			local buffer = BitBuffer.new()
			buffer._buffer = {1, -1}
			buffer._index = 64

			expect(buffer:ReadInt(14)).to.be.equal(0)
		end)
	end)

	describe("De/Serialization", function()
		it("Fixed bit width", function()
			for bw = 1, 32 do
				local buffer = BitBuffer.new(bw*N/2)
				local rand = Random.new()
				local values = table.create(N/2)

				for i = 1, N/2 do
					local int = rand:NextInteger(-2^(bw - 1), 2^(bw - 1) - 1)
					values[i] = int
					buffer:WriteInt(bw, int)
				end
				buffer._index = 0

				for i = 1, N/2 do
					expect(buffer:ReadInt(bw)).to.be.equal(values[i])
				end
			end
		end)

		it("Random bit width", function()
			local buffer = BitBuffer.new()
			local rand = Random.new()
			local values = table.create(N)

			for i = 1, N do
				local bw = rand:NextInteger(1, 32)
				local int = rand:NextInteger(-2^(bw - 1), 2^(bw - 1) - 1)
				buffer:WriteInt(bw, int)
				values[i] = {bw, int}
			end
			buffer._index = 0

			for i = 1, N do
				expect(buffer:ReadInt(values[i][1])).to.be.equal(values[i][2])
			end
		end)

		it("Zero", function()
			local buffer = BitBuffer.new(sums(32))
			for bw = 1, 32 do
				buffer:WriteInt(bw, 0)
			end

			buffer._index = 0
			for bw = 1, 32 do
				expect(buffer:ReadInt(bw)).to.be.equal(0)
			end
		end)

		it("Max value", function()
			local buffer = BitBuffer.new(sums(32))
			for bw = 1, 32 do
				buffer:WriteInt(bw, 2^(bw - 1) - 1)
			end

			buffer._index = 0
			for bw = 1, 32 do
				expect(buffer:ReadInt(bw)).to.be.equal(2^(bw - 1) - 1)
			end
		end)

		it("Min value", function()
			local buffer = BitBuffer.new(sums(32))
			for bw = 1, 32 do
				buffer:WriteInt(bw, -2^(bw - 1))
			end

			buffer._index = 0
			for bw = 1, 32 do
				expect(buffer:ReadInt(bw)).to.be.equal(-2^(bw - 1))
			end
		end)
	end)
end