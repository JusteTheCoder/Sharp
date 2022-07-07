local Sharp = _G.Sharp

local Net = Sharp.Library.Net

local MySingleton = Net.with("MySingleton", {
    value = "Value says hello!",
})

MySingleton:netAdd(Net.Trove)

MySingleton.myEvent:Connect(function(message)
    print(message)
end)

MySingleton.myAsyncEvent:setTimeout(15)
MySingleton.myAsyncEvent:callServer()
:andThen(function(...)
    print(...)
end)

MySingleton.myEvent:sendToServer(1111, workspace)

return MySingleton