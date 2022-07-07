local Sharp = _G.Sharp

local Net = Sharp.Library.Net
local t = Sharp.Library.t

local Players = game:GetService("Players")

local MySingleton = Net.with("MySingleton", {
    value = "Value says hello!",
})

MySingleton:netAdd({
    myEvent = Net.Type.event(),
    myAsyncEvent = Net.Type.asyncEvent()
})

MySingleton.myEvent:inboundProcess(function(number)
    print(number)
    return math.clamp(number, 0, 10)
end, function(number)
    return number * 2
end)

MySingleton.myAsyncEvent:outboundProcess(function(string)
    return string:match("^%w+")
end)

MySingleton.myEvent:useInboundMiddleware({
    Net.Middleware.typeCheck(t.string),
})

MySingleton.myEvent:useOutboundMiddleware({
    Net.Middleware.block(function(client, ...)
        return client.Name:len() > 5
    end)
})

MySingleton.myEvent:Connect(function(client, message)
    print("Client " .. client.Name .. " fired myEvent with message " .. message)
    --> "Client client fired myEvent with message Hello World!"
end)

MySingleton.myAsyncEvent:setCallback(function(client, ...)
    return "Hello " .. client.Name .. "from server!"
end)

task.spawn(function()
    task.wait(3)
    MySingleton.myEvent:sendToClient(Players:FindFirstChildWhichIsA("Player"), "Hello World!")
end)

return MySingleton