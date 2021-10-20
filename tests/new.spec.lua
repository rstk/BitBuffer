local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitBuffer = require(ReplicatedStorage.Packages.BitBuffer)

return function()
	it("Should construct a new BitBuffer", function()
		expect(BitBuffer.is(BitBuffer.new())).to.be.equal(true)
	end)
end