local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitBuffer = require(ReplicatedStorage.Packages.BitBuffer)

return function()
	local N = script.Parent.TestN.Value

	describe("General tests", function()
		it("Should not throw when reading", function()
			local buffer = BitBuffer.new()
			buffer._buffer = {1 + math.pow(2, 16)}

			expect(function()
				buffer:ReadFloat32()
			end).never.to.throw()
		end)

		it("Should not throw when writing", function()
			expect(function()
				BitBuffer.new():WriteFloat32(0.5)
			end)
		end)

		it("Should read zeroes when going past the buffer", function()
			local buffer = BitBuffer.new()
			buffer._buffer = {math.pow(2, 32) - 1}
			buffer:SetCursor(32)

			expect(buffer:ReadFloat32()).to.be.equal(0)
		end)
	end)

	describe("De/Serialization", function()
		local function getEpsilon(value: number): number
			return 1 / math.pow(2, 23 - math.log(value, 2))
		end

		local function near(value: number, epsilon: number): ((comparedValue: number) -> ())
			-- use a callback to get better failing info
			return function(comparedValue: number): ((test: boolean) -> ())
				return function()
					if not
						(comparedValue - epsilon <= value and
						comparedValue + epsilon >= value)
					then
						error(string.format("expected %.6f ~ %.6f, got %.6f", value, epsilon, comparedValue))
					end
				end
			end
		end

		local function Test(bound: number, expect: (any) -> Keys)
			local rand = Random.new()
			local tests = table.create(N * 64)
			local buffer = BitBuffer.new()
			local epsilon = getEpsilon(bound)

			for i = 1, N * 64 do
				local float = (rand:NextNumber() - 0.5) * bound * 2
				buffer:WriteFloat32(float)
				tests[i] = near(float, epsilon)
			end

			buffer:ResetCursor()
			for _, t in ipairs(tests) do
				expect(t(buffer:ReadFloat32())).never.to.throw()
			end
		end

		it("Small floats", function()
			Test(math.pow(2, 8), expect)
		end)

		it("Medium floats", function()
			Test(math.pow(2, 12), expect)
		end)

		it("Large floats", function()
			Test(math.pow(2, 16), expect)
		end)

		it("Very large floats", function()
			Test(math.pow(2, 20), expect)
		end)

		it("Max safe value", function()
			local buffer = BitBuffer.new()
			buffer:WriteFloat32(math.pow(2, 23) - 1)
			buffer:ResetCursor()
			expect(buffer:ReadFloat32()).to.be.equal(math.pow(2, 23) - 1)
		end)

		it("Min safe value", function()
			local buffer = BitBuffer.new()
			buffer:WriteFloat32(-1 * math.pow(2, 23) - 1)
			buffer:ResetCursor()
			expect(buffer:ReadFloat32()).to.be.equal(-1 * math.pow(2, 23) - 1)
		end)

		it("Zero", function()
			local buffer = BitBuffer.new()
			buffer:WriteUInt(32, math.pow(2, 32) - 1)
			buffer:WriteFloat32(0)
			buffer._index = 32

			expect(buffer:ReadFloat32()).to.be.equal(0)
		end)

		it("NaN", function()
			local buffer = BitBuffer.new()
			buffer:WriteFloat32(0 / 0)
			buffer:ResetCursor()

			local v = buffer:ReadFloat32()
			expect(v ~= v).to.be.equal(true)
		end)

		it("Infinities", function()
			local buffer = BitBuffer.new()
			buffer:WriteFloat32(math.huge)
			buffer:WriteFloat32(-math.huge)

			buffer:ResetCursor()
			expect(buffer:ReadFloat32()).to.be.equal(math.huge)
			expect(buffer:ReadFloat32()).to.be.equal(-math.huge)
		end)
	end)
end