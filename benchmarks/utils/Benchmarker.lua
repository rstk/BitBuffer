local RUN_N = 1024

local function ExtractBenchmarks(modules: {Instance}): {[string]: {}}
	local benchmarks = {}
	for _, instance in ipairs(modules) do
		if instance:IsA("ModuleScript") then
			benchmarks[instance.Name] = require(instance:Clone())
		end
	end
	return benchmarks
end

local Benchmarker = {}

local RowOrder = {
	WriteInt16 = 1;
	ReadInt16 = 2;
	WriteInt32 = 3;
	ReadInt32 = 4;
	WriteUInt16 = 5;
	ReadUInt16 = 6;
	WriteUInt32 = 7;
	ReadUInt32 = 8;
	WriteFloat32 = 9;
	ReadFloat32 = 10;
	WriteFloat64 = 11;
	ReadFloat64 = 12;
	WriteStringL10 = 13;
	ReadStringL10 = 14;
	WriteStringL100 = 15;
	ReadStringL100 = 16;
	WriteStringL1000 = 17;
	ReadStringL1000 = 18;
	WriteBytesL10 = 19;
	ReadBytesL10 = 20;
	WriteBytesL100 = 21;
	ReadBytesL100 = 22;
	WriteBytesL1000 = 23;
	ReadBytesL1000 = 24;
	WriteBool = 25;
	ReadBool = 26;
	WriteChar = 27;
	ReadChar = 28;
}

function Benchmarker.formatResults(results)
	local tests = {}
	for testName in next, select(2, next(results)) do
		table.insert(tests, testName)
	end

	local tables = {}
	for _, testName in ipairs(tests) do
		-- wow. this code sucks
		local entries = {}
		local sorted = {}

		for authorName, allResults in next, results do
			local testResults = allResults[testName]
			if testResults then
				local fiftiethPercentile = testResults["50th %"]
				local entry = {
					author = authorName;
					alignment = "Aligned"; -- Unaligned tests are TODO
					fiftiethPercentile = testResults["50th %"];
					average = testResults.average;
					delta = nil;
				}

				table.insert(sorted, {entry = entry, fiftiethPercentile = fiftiethPercentile})
				table.insert(entries, entry)
			end
		end

		table.sort(sorted, function(a, b)
			return a.fiftiethPercentile < b.fiftiethPercentile
		end)

		local highest = sorted[#sorted].fiftiethPercentile
		for index, entry in ipairs(sorted) do
			entry.entry.delta = string.format("%.2fx", highest / entry.fiftiethPercentile)
			sorted[index] = entry.entry
		end

		tables[testName] = sorted
	end

	-- actually format it
	local formattedTables = {}
	for tabName, entries in next, tables do
		local title = "#### " .. tabName
		-- the &nbsp; things are there so that the tables render more nicely on github
		local top = "| Author &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp; 50th % | Average | Delta |"
		local mid = "| :----- | -----: | ------: | ----: |"

		local rows = table.create(#entries)
		for index, entry in ipairs(entries) do
			local baseString = if index == 1 then "| **%s** | **%.4f** | **%.4f** | **%s** |" else "| %s | %.4f | %.4f | %s |"
			rows[index] = string.format(baseString, entry.author, entry.fiftiethPercentile, entry.average, entry.delta)
		end

		formattedTables[RowOrder[tabName]] = table.concat({title, top, mid}, "\n") .. "\n" .. table.concat(rows, "\n")
	end

	local sections = {}
	assert(#formattedTables % 2 == 0, "uneven number of tables")
	for i = 2, #formattedTables, 2 do
		table.insert(sections, formattedTables[i] .. "\n" .. formattedTables[i - 1] .. "\n\n---")
	end

	return "\n" .. table.concat(sections, "\n\n") .. "\n"
end

function Benchmarker.runAll(benchmarkModules: {Instance})
	local benchmarks = ExtractBenchmarks(benchmarkModules)
	local fullResults = {}

	local seeds = table.create(RUN_N)
	for i = 1, RUN_N do
		seeds[i] = math.random(0, 2 ^ 31 - 1)
	end

	for columnName, tests in next, benchmarks do
		local rows = {}
		for testName, testFns in next, tests do
			local results = Benchmarker.run(testFns, seeds)
			rows["Read" .. testName] = results.read
			rows["Write" .. testName] = results.write
		end

		fullResults[columnName] = rows
	end

	return fullResults
end

type TestFns<B, R> = {
	ParameterGenerator: (seed: number) -> (B, R),
	Write: (B, R) -> (),
	ResetCursor: (B) -> (),
	Read: (B) -> (),
}

function Benchmarker.run<B, R>(testFns: TestFns<B, R>, seeds: {number})
	local inputPairs = table.create(RUN_N)
	for i = 1, RUN_N do
		inputPairs[i] = {testFns.ParameterGenerator(seeds[i])}
	end

	local WriteFn = testFns.Write
	local ReadFn = testFns.Read

	local writeResults = table.create(RUN_N)
	local readResults = table.create(RUN_N)

	-- WRITE TESTS
	for i = 1, RUN_N do
		local inputs = inputPairs[i]
		local bitbuffer, r = inputs[1], inputs[2]

		local initTime = os.clock()
		WriteFn(bitbuffer, r)
		local endTime = os.clock()
		initTime *= 1000
		endTime *= 1000
		local delta = endTime - initTime
		writeResults[i] = delta
	end

	-- READ TESTS
	for i = 1, RUN_N do
		local bitbuffer = inputPairs[i][1]
		-- reset buffer
		testFns.ResetCursor(bitbuffer)

		local initTime = os.clock()
		ReadFn(bitbuffer)
		local endTime = os.clock()
		initTime *= 1000
		endTime *= 1000
		local delta = endTime - initTime
		readResults[i] = delta
	end

	table.sort(writeResults)
	table.sort(readResults)

	local function summate(array)
		local sum = 0
		for _, value in ipairs(array) do
			sum += value
		end
		return sum
	end

	return {
		write = {
			["50th %"] = writeResults[math.floor(RUN_N / 2)];
			["average"] = summate(writeResults) / RUN_N;
		};

		read = {
			["50th %"] = readResults[math.floor(RUN_N / 2)];
			["average"] = summate(readResults) / RUN_N;
		};
	}
end

return Benchmarker
