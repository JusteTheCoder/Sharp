local Sharp = _G.Sharp

local chain = Sharp.Package.Net.chain

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
	if self._outboundMiddleware == nil then
		return true
	end

	for _, middleware in ipairs(self._outboundMiddleware) do
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
	if self._inboundMiddleware == nil then
		return true
	end

	for _, middleware in ipairs(self._inboundMiddleware) do
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

function TypeClass:outboundProcess(...)
	local fn = ...
	if select('#', ...) > 1 then
		fn = chain(...)
	end

	self._processOutboundMiddleware = fn
	return self
end

--[=[
    Sets a function which will be called when the NetType receives data
    and modifies the arguments before sending them to the listeners.
    Can be used for deserializing data.

    @param fn (...:any) -> ...:any
    @return self
]=]

function TypeClass:inboundProcess(...)
	local fn = ...
	if select('#', ...) > 1 then
		fn = chain(...)
	end

	self._processInboundMiddleware = fn
	return self
end

--[=[
    Adds middleware to the call process.

    @param middleware {[NetMiddlewareDefinition]}
    @return self
]=]

function TypeClass:useOutboundMiddleware(middleware)
	local middlewareTable = self._outboundMiddleware

	if middlewareTable == nil then
		middlewareTable = {}
		self._outboundMiddleware = middlewareTable
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

function TypeClass:useInboundMiddleware(middleware)
	local middlewareTable = self._inboundMiddleware

	if middlewareTable == nil then
		middlewareTable = {}
		self._inboundMiddleware = middlewareTable
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
