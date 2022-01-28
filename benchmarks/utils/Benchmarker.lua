local RUN_N = 256

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
			-- not a typo
			return a.fiftiethPercentile > b.fiftiethPercentile
		end)

		local highest = nil
		for index, entry in ipairs(sorted) do
			if highest == nil then
				highest = entry.fiftiethPercentile
				entry.entry.delta = "1.00x"
			else
				entry.entry.delta = string.format("%.2fx", highest / entry.fiftiethPercentile)
			end

			sorted[index] = entry.entry
		end

		tables[testName] = entries
	end

	-- actually format it
	local formattedTables = {}
	for tabName, entries in next, tables do
		local title = "#### " .. tabName
		local top = "| Author | Alignment | 50th % | Average | Delta |"
		local mid = "| :----- | --------- | :----: | :-----: | ----: |"

		local rows = table.create(#entries)
		for index, entry in ipairs(entries) do
			rows[index] = string.format(
				"| %s | %s | %.4f | %.4f | %s |",
				entry.author,
				entry.alignment,
				entry.fiftiethPercentile,
				entry.average,
				entry.delta
			)
		end

		table.insert(formattedTables, table.concat({title, top, mid}, "\n") .. "\n" .. table.concat(rows, "\n"))
	end

	return "\n" .. table.concat(formattedTables, "\n\n") .. "\n"
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
