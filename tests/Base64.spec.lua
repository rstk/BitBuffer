local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitBuffer = require(ReplicatedStorage.Packages.BitBuffer)

return function()
	local Base64Char = table.create(64)
	do
		local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

		for i = 1, 64 do
			Base64Char[i] = string.sub(alphabet, i, i)
		end
	end

	local N = script.Parent.TestN.Value

	describe("General tests", function()
		local buffers = table.create(N)
		local base64Export = table.create(N)
		for i = 1, N do
			local bitbuffer = BitBuffer.new()
			local internalBuffer = bitbuffer._buffer
			local rand = Random.new()

			for j = 1, N do
				internalBuffer[j] = rand:NextInteger(0, 2^32 - 1)
			end

			buffers[i] = bitbuffer
			base64Export[i] = bitbuffer:ToBase64()
		end

		it("Should not throw when serializing", function()
			for i = 1, N do
				expect(function()
					buffers[i]:ToBase64()
				end).never.to.throw()
			end
		end)

		it("Should not throw when deserializing", function()
			for i = 1, N do
				expect(function()
					BitBuffer.FromBase64(base64Export[i])
				end).never.to.throw()
			end
		end)

		it("Should throw when FromBase64 is fed with invalid Base64", function()
			local rand = Random.new()

			for i = 1, N do
				local validString = base64Export[i]
				local replaceIndex = rand:NextInteger(1, #validString)
				local invalidString =
					string.sub(validString, 1, replaceIndex) ..
					string.char(rand:NextInteger(123, 255)) ..
					string.sub(validString, replaceIndex, #validString)

				expect(function()
					BitBuffer.FromBase64(invalidString)
				end).to.throw()
			end
		end)

		it("Should not throw when FromBase64 is fed with empty/small strings", function()
			local rand = Random.new()

			for _ = 1, N do
				expect(function()
					BitBuffer.FromBase64(string.rep(Base64Char[rand:NextInteger(1, 64)], rand:NextInteger(0, 4)))
				end).never.to.throw()
			end
		end)

		it("Should not fill the buffer more than it needs to", function()
			for i = 1, N do
				local buffer = BitBuffer.FromBase64(base64Export[i])._buffer
				expect(buffer[N+1] == 0 or buffer[N+1] == nil).to.be.equal(true)
				expect(buffer[N+2]).never.to.be.ok()
			end
		end)

		it("Should work with empty/small buffers", function()
			local rand = Random.new()

			for _ = 1, N do
				local buffer = BitBuffer.new()
				local size = rand:NextInteger(0, 4)

				for _ = 2, size, 2 do
					table.insert(buffer._buffer, rand:NextInteger(1, 2^32 - 1))
				end
				if size % 2 ~= 0 then
					table.insert(buffer._buffer, rand:NextInteger(1, 2^16 - 1))
				end

				local newBuffer = BitBuffer.FromBase64(buffer:ToBase64())
				local zeroReached = false
				for i = 1, 4 do
					local deserializedValue = newBuffer._buffer[i]

					if zeroReached then
						expect(deserializedValue).to.be.equal(buffer._buffer[i])
					elseif deserializedValue == nil then
						expect(buffer._buffer[i]).never.to.be.ok()
					else
						expect(deserializedValue).to.be.equal(buffer._buffer[i] or 0)
					end

					if deserializedValue  == 0 then
						zeroReached = true
					end
				end
			end
		end)
	end)

	describe("De/Serialization", function()
		local rand = Random.new()

		local function RandomBuffer(size: number): BitBuffer.BitBuffer
			local buffer = BitBuffer.new(size * 32)

			for i = 1, size do
				buffer._buffer[i] = rand:NextInteger(0, 2^32 - 1)
			end

			return buffer
		end

		local function Test(size: number, expect: (any) -> Keys)
			local buffer = RandomBuffer(size)

			local newBuffer = BitBuffer.FromBase64(buffer:ToBase64())
			for i = 1, size do
				expect(newBuffer._buffer[i]).to.be.equal(buffer._buffer[i])
			end

			for i = 1, 3 do
				local value = newBuffer._buffer[size + i]
				expect(value == 0 or value == nil).to.be.equal(true)
			end
		end

		it("Small size", function()
			for _ = 1, N do
				Test(rand:NextInteger(0, 4), expect)
			end
		end)

		it("Medium size", function()
			for _ = 1, N do
				Test(rand:NextInteger(5, 32), expect)
			end
		end)

		it("Large size", function()
			for _ = 1, N do
				Test(rand:NextInteger(33, 256), expect)
			end
		end)
	end)
end