local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Benchmarker = require(ReplicatedStorage.Utils.Benchmarker)
local results = Benchmarker.runAll(ReplicatedStorage.Benchmarks:GetChildren())
print(Benchmarker.formatResults(results))
