-- TODO: refactor this garbage lmao
local b = {}

type bSettings = {
	name: string,
	modules: {[number]: ModuleScript},
	timePerModule: number,
	stdout: ((string) -> ())?
}

type bObject = {
	start: () -> (),
	done: () -> ()
}

function b._getLoader(): (ModuleScript) -> any
	local success, useLoadModule = pcall(function()
		return settings():GetFFlag("EnableLoadModule")
	end)

	if not useLoadModule or not success and pcall(function()
		debug["loadmodule"](Instance.new("ModuleScript"))
	end) then
		useLoadModule = true
	end

	return useLoadModule and function(module: ModuleScript): any
		return debug["loadmodule"](module)()
	end or require
end

function b.runBenchmark(settings: bSettings): string
	local loader = b._getLoader()

	local benchmarkRunners: {[string]: (bObject) -> ()} = {}
	for _, moduleScript in ipairs(settings.modules) do
		local name = string.match(moduleScript.Name, "^([%w_]+)%.b$")
		if name then
			local runner = loader(moduleScript)
			if type(runner) ~= "function" then
				error("module %s didn't return a function", moduleScript:GetFullName())
			end

			benchmarkRunners[name] = runner
		end
	end

	local benchmarkResults = {}

	for runnerName: string, runnerFunc: (bObject) -> () in next, benchmarkRunners do
		local time, totalRuns = b._runRunner(runnerFunc, settings)
		benchmarkResults[runnerName] = {
			time = time;
			totalRuns = totalRuns;
		}
	end

	local formattedResults = b._formatResults(benchmarkResults)
	if settings.stdout then
		settings.stdout(string.format("\nBenchmark %sresults:\n%s",
			settings.name and settings.name .. " " or "",
			formattedResults
		))
	end

	return formattedResults
end

function b._runRunner(runner: (bObject) -> (), settings: bSettings): number
	local TIME_PER_RUNNER = settings.timePerModule

	local totalRuns = 0
	local startEpoch = nil
	local doneEpoch = nil

	local bObject: bObject = {
		start = function()
			startEpoch = os.clock()
		end;

		done = function()
			doneEpoch = os.clock()
		end;
	}

	local results = {}

	local superStart = os.clock()
	while superStart + TIME_PER_RUNNER > os.clock() do
		runner(bObject)

		if startEpoch == nil then
			error("Runner didn't start")
		elseif doneEpoch == nil then
			error("Runner didn't end")
		end

		local deltaTime = doneEpoch - startEpoch

		if deltaTime <= 1e-5 then
			error("Runner too fast")
		end

		table.insert(results, deltaTime)
		totalRuns += 1
	end

	table.sort(results)

	return results[math.floor(#results / 2)] * 1000, totalRuns
end

---formats to a markdown table
function b._formatResults(benchmarkResults: {[string]: number})
	table.sort(benchmarkResults, function(o1, o2)
		return o1.time < o2.time
	end)

	local COLUMN_PADDING = 2

	local function intLen(int: number): number
		if math.floor(int) == 0 then
			return 1
		end

		return math.floor(math.log(math.floor(int), 10)) + 1
	end

	local longestNameLength = 0
	local longestResultLength = 0
	local resultsArray = {}
	for name, result in next, benchmarkResults do
		longestNameLength = math.max(longestNameLength, #name)
		longestResultLength = math.max(longestResultLength, intLen(result.time))
		table.insert(resultsArray, {
			name = name;
			time = result.time;
		})
	end

	table.sort(resultsArray, function(lower, upper)
		-- todo: sort by smart alphabetical order (ie handle numbers correctly)
		return lower.name < upper.name
	end)

	local formattedResults = table.create(#resultsArray)
	formattedResults[1] = "| Method | Result (ms) |"
	formattedResults[2] = "|:-------|------------:|"
	for _, bench in ipairs(resultsArray) do
		table.insert(formattedResults, string.format("|%s%s|%s%.4f|",
			bench.name,
			string.rep(" ", longestNameLength - #bench.name + COLUMN_PADDING),
			string.rep(" ", longestResultLength - intLen(bench.time) + COLUMN_PADDING),
			bench.time
		))
	end

	return table.concat(formattedResults, "\n")
end

for t = 3, 1, -1 do
	print(string.format("running benchmarks in %d...", t))
	task.wait(1)
end

print("running benchmarks now...")
task.wait(0.1)

b.runBenchmark({
	name = "Read";
	modules = script.Parent.Read:GetChildren();
	timePerModule = 1;
	stdout = print;
})

b.runBenchmark({
	name = "Write";
	modules = script.Parent.Write:GetChildren();
	timePerModule = 1;
	stdout = print;
})

b.runBenchmark({
	name = "Serialization";
	modules = script.Parent.Serialization:GetChildren();
	timePerModule = 1;
	stdout = print;
})