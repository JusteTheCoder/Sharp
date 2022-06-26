local Sharp = _G.Sharp

--[=[
	Manages the client middleware.

	@private
	@class ClientInterface
]=]

local Middleware = Sharp.package.Net.Middleware

local function iterate(netType, item, args)
	local status, result = true, args

	while item do
		status, result = item:fn(netType, result)

		if not status then
			return status, result
		end

		item = item._next
	end

	return status, result
end

local ClientInterface = {}
ClientInterface.__index = ClientInterface

--[=[
	Processes the result of the event.

	@private
	@param ... any

	@return boolean, any
]=]

function ClientInterface:processResult(...)
	return iterate(self[Middleware.result], { ... })
end

--[=[
	Processes the arguments.

	@private
	@param ... any

	@return boolean, any
]=]

function ClientInterface:processArgument(...)
	return iterate(self[Middleware.argument], { ... })
end

--[=[
	Adds middleware to the client interface.

	@private
	@param middlewareArray {[Middleware]}
]=]

function ClientInterface:extend(middlewareArray)
	table.sort(middlewareArray, function(a, b)
		local aPriority = a.priority or Middleware.priority.normal
		local bPriority = b.priority or Middleware.priority.normal

		return aPriority > bPriority
	end)

	for _, middleware in middlewareArray do
		if not Middleware.is(middleware) then
			continue
		end

		middleware._next = self[middleware.cycle]
		self[middleware.cycle] = middleware
	end
end

--[=[
	Creates a new client middleware interface.

	@param netType [NetTypes.NetType]
	@return ClientInterface
]=]

function ClientInterface.new(netType)
	return setmetatable({ _netType = netType }, ClientInterface)
end

return ClientInterface
