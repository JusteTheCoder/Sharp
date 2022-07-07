local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sharp = require(ReplicatedStorage:WaitForChild("Sharp"))

Sharp.addSingletons(script.Singletons)
Sharp.addLibraries(script.Libraries)
Sharp.addLibraries(ReplicatedStorage.Source.Libraries)

Sharp.onStart(function()
    print("Sharp is ready!")
end)

task.spawn(function()
    Sharp.await() -- Yield until Sharp is ready.
    print("Awaited!")
end)

Sharp.start() -- Yields if necessary
print("Started!")