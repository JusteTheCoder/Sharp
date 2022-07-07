local Sharp = _G.Sharp

--[=[
    A base Net type which all other Net types inherit from.

    @class TypeClass
]=]

local TypeClass = {}
TypeClass.__index = TypeClass

--[=[
    Processes call data.

    @private
    @param client Instance
    @param ... any
    @return boolean, string?
]=]

function TypeClass:_processCall(client, ...)
    if self._callMiddleware == nil then
        return true
    end

    for _, middleware in ipairs(self._callMiddleware) do
        local result, err = middleware(client, ...)

        if result == false then
            return false, err
        end
    end

    return true
end

--[=[
    Processes received data.

    @private
    @param client Instance
    @param ... any
    @return boolean, string?
]=]

function TypeClass:_processReceive(client, ...)
    if self._receiveMiddleware == nil then
        return true
    end

    for _, middleware in ipairs(self._receiveMiddleware) do
        local result, err = middleware(client, ...)

        if result == false then
            return false, err
        end
    end

    return true
end

--[=[
    Sets a function which will be called when the NetType is called
    and modifies the arguments before calling the function.
    Can be used for serializing data.

    @param fn (...:any) -> ...:any
    @return self
]=]

function TypeClass:onCallProcess(fn)
    self._processCallFunction = fn
    return self
end

--[=[
    Sets a function which will be called when the NetType receives data
    and modifies the arguments before sending them to the listeners.
    Can be used for deserializing data.

    @param fn (...:any) -> ...:any
    @return self
]=]

function TypeClass:onReceiveProcess(fn)
    self._processReceiveFunction = fn
    return self
end

--[=[
    Adds middleware to the call process.

    @param middleware {[NetMiddlewareDefinition]}
    @return self
]=]

function TypeClass:onCallMiddleware(middleware)
    local middlewareTable = self._callMiddleware

    if middlewareTable == nil then
        middlewareTable = {}
        self._callMiddleware = middlewareTable
    end

    for _, middlewareConstructor in ipairs(middleware) do
        table.insert(middlewareTable, middlewareConstructor(self))
    end

    return self
end

--[=[
    Adds middleware to the receive process.

    @param middleware {[NetMiddlewareDefinition]}
    @return self
]=]

function TypeClass:onReceiveMiddleware(middleware)
    local middlewareTable = self._receiveMiddleware

    if middlewareTable == nil then
        middlewareTable = {}
        self._receiveMiddleware = middlewareTable
    end

    for _, middlewareConstructor in ipairs(middleware) do
        table.insert(middlewareTable, middlewareConstructor(self))
    end

    return self
end

--[=[
    Connects to the NetType.

    @param fn ()->(...:any)
    @return [Signal]
]=]

function TypeClass:Connect(fn)
    return self._signal:Connect(fn)
end

return TypeClass