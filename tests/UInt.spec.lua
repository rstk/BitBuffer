local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitBuffer = require(ReplicatedStorage.Packages.BitBuffer)

local function sums(n)
	return (n * n + n) / 2
end

return function()
	local N = script.Parent.TestN.Value

	describe("General tests", function()
		it("Should not throw when writing", function()
			local rand = Random.new()

			for bw = 1, 32 do
				expect(function()
					BitBuffer.new(bw):WriteUInt(bw, rand:NextInteger(0, math.pow(2, bw) - 1))
				end).never.to.throw()
			end
		end)

		it("Should not throw when reading", function()
			for bw = 1, 32 do
				local buffer = BitBuffer.new()
				buffer._buffer = {Random.new():NextInteger(0, math.pow(2, bw) - 1)}

				expect(function()
					buffer:ReadUInt(bw)
				end).never.to.throw()
			end
		end)

		it("Should read zeroes when going past the buffer", function()
			local buffer = BitBuffer.new()
			buffer._buffer = {1, 1}
			buffer._index = 64

			expect(buffer:ReadUInt(14)).to.be.equal(0)
		end)
	end)

	describe("De/Serialization", function()
		it("Should write and read integers with a fixed bit width correctly", function()
			for bw = 1, 32 do
				local buffer = BitBuffer.new(bw * N / 2)
				local rand = Random.new()
				local values = table.create(N / 2)

				for i = 1, N / 2 do
					local int = rand:NextInteger(0, math.pow(2, bw) - 1)
					values[i] = int
					buffer:WriteUInt(bw, int)
				end
				buffer:ResetCursor()

				for _, v in ipairs(values) do
					expect(buffer:ReadUInt(bw)).to.be.equal(v)
				end
			end
		end)

		it("Should write and read integers with a random bit width correctly", function()
			local buffer = BitBuffer.new()
			local rand = Random.new()
			local values = table.create(N)

			for i = 1, N do
				local bw = rand:NextInteger(1, 32)
				local int = rand:NextInteger(0, math.pow(2, bw) - 1)
				buffer:WriteUInt(bw, int)
				values[i] = {bw, int}
			end
			buffer:ResetCursor()

			for _, v in ipairs(values) do
				expect(buffer:ReadUInt(v[1])).to.be.equal(v[2])
			end
		end)

		it("Should write and read zero correctly", function()
			local buffer = BitBuffer.new(sums(32))
			for bw = 1, 32 do
				buffer:WriteUInt(bw, 0)
			end

			buffer:ResetCursor()
			for bw = 1, 32 do
				expect(buffer:ReadUInt(bw)).to.be.equal(0)
			end
		end)

		it("Should write and read the maximum value correctly", function()
			local buffer = BitBuffer.new(sums(32))
			for bw = 1, 32 do
				buffer:WriteUInt(bw, math.pow(2, bw) - 1)
			end

			buffer:ResetCursor()
			for bw = 1, 32 do
				expect(buffer:ReadUInt(bw)).to.be.equal(math.pow(2, bw) - 1)
			end
		end)

		it("Should overflow correctly", function()
			for bw = 1, 32 do
				local buffer = BitBuffer.new()
				local values = table.create(N)
				local max = math.pow(2, bw)

				for offset = 1, N do
					local v = offset * math.floor(max / 4)
					buffer:WriteUInt(bw, v)
					values[offset] = v
				end
				buffer:ResetCursor()

				for _, v in ipairs(values) do
					expect(buffer:ReadUInt(bw)).to.be.equal(v % max)
				end
			end
		end)
	end)
end