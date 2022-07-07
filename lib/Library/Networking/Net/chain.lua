--[=[
    Allows for chaining multiple functions together.
    Useful for onCallProcess and onReceiveProcess functions.

	```lua
	someEvent:onReceiveProcess(Net.chain(deserialize, limitToBox(10)))
	```

    @within Net
    @param .. (...: any) -> any
    @return (...: any) -> any
]=]

local function chain(...)
    local functions = select("#", ...)

    local function wrapCallback(fn, callback)
        return function(...)
            return callback(fn(...))
        end
    end

    local callbackFn = select(functions, ...)
    for i = functions - 1, 1, -1 do
        callbackFn = wrapCallback(select(i, ...), callbackFn)
    end

    return callbackFn
end

return chain