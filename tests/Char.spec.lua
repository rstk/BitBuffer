local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitBuffer = require(ReplicatedStorage.Packages.BitBuffer)

return function()
	local N = script.Parent.TestN.Value

	describe("General tests", function()
		it("Should not throw when reading", function()
			local buffer = BitBuffer.new()
			buffer._buffer = {255}

			expect(function()
				buffer:ReadChar()
			end).never.to.throw()
		end)

		it("Should not throw when writing", function()
			expect(function()
				BitBuffer.new():WriteChar("A")
			end)
		end)

		it("Should read zeroes when going past the buffer", function()
			local buffer = BitBuffer.new()
			buffer:WriteChar("A")
			buffer:WriteChar("\7")

			buffer:SetCursor(16)
			expect(buffer:ReadChar()).to.be.equal("\0")
		end)

		it("Should write only the first character", function()
			local buffer = BitBuffer.new()
			buffer:WriteChar("ABCD")

			expect(buffer._buffer[1]).to.be.equal(65)
		end)

		it("Should throw if string is empty", function()
			expect(function()
				BitBuffer.new():WriteChar("")
			end).to.throw()
		end)
	end)

	describe("De/Serializing", function()
		it("< 4", function()
			for n = 1, 3 do
				local rand = Random.new()
				local buffer = BitBuffer.new()
				local values = table.create(n)

				for i = 1, n do
					local char = string.char(rand:NextInteger(0, 255))
					buffer:WriteChar(char)
					values[i] = char
				end

				buffer:ResetCursor()
				for _, v in ipairs(values) do
					expect(buffer:ReadChar()).to.be.equal(v)
				end
			end
		end)

		it(">= 4", function()
			local rand = Random.new()
			for _ = 1, N do
				local n = rand:NextInteger(4, 64)
				local buffer = BitBuffer.new()
				local values = table.create(n)

				for i = 1, n do
					local char = string.char(rand:NextInteger(0, 255))
					buffer:WriteChar(char)
					values[i] = char
				end

				buffer:ResetCursor()
				for _, v in ipairs(values) do
					expect(buffer:ReadChar()).to.be.equal(v)
				end
			end
		end)
	end)
end