local function Integer(signed: boolean)
	return function(bitWidth: number)
		return function(seed: number, listLength: number)
			local r = Random.new(seed)
			local minInt, maxInt
			if signed then
				minInt = -2 ^ (bitWidth - 1)
				maxInt = 2 ^ (bitWidth - 1) - 1
			else
				minInt = 0
				maxInt = 2 ^ bitWidth - 1
			end

			local list = table.create(listLength)
			for i = 1, listLength do
				list[i] = r:NextInteger(minInt, maxInt)
			end

			return list
		end
	end
end

local function Bytes(byteCount: number)
	return function(seed: number, listLength: number)
		local r = Random.new(seed)
		local list = table.create(listLength)
		for i = 1, listLength do
			list[i] = string.rep(r:NextInteger(0, 255), byteCount)
		end

		return list
	end
end

local function Bool(seed: number, listLength: number)
	local r = Random.new(seed)
	local list = table.create(listLength)
	for i = 1, listLength do
		list[i] = r:NextNumber() > 0.5
	end

	return list
end

local function Float(seed: number, listLength: number)
	local r = Random.new(seed)
	local list = table.create(listLength)
	for i = 1, listLength do
		list[i] = r:NextNumber() * (2 ^ 20)
	end

	return list
end

local Int = Integer(true)
local UInt = Integer(false)

return {
	Int16 = Int(16);
	Int32 = Int(32);
	UInt16 = UInt(16);
	UInt32 = UInt(32);
	Bytes10 = Bytes(10);
	Bytes100 = Bytes(100);
	Bytes1000 = Bytes(1000);
	Bool = Bool;
	Float = Float;
	Char = Bytes(1);
}
