local Sharp = _G.Sharp

--[=[
	Manages the server middleware.

	@private
	@class ServerInterface
]=]

local Middleware = Sharp.package.Net.Middleware

local function iterate(netType, item, args, resultFn)
	local status, result = true, args

	while item do
		status, result = item:fn(netType, resultFn and resultFn(result) or result)

		if not status then
			return status, result
		end

		item = item._next
	end

	return status, result
end

local ServerInterface = {}
ServerInterface.__index = ServerInterface

--[=[
	Processes the result of the event.

	@private
	@param client Instance
	@param ... any

	@return boolean, any
]=]

function ServerInterface:processResult(client, ...)
	local function pass(result)
		return client, result
	end

	return iterate(self[Middleware.result], { ... }, pass)
end

--[=[
	Processes the arguments.

	@private
	@param ... any

	@return boolean, any
]=]

function ServerInterface:processArgument(...)
	return iterate(self[Middleware.argument], { ... })
end

--[=[
	Filters calls from server to client.

	@private
	@param client Instance

	@return boolean
]=]

function ServerInterface:processClient(client)
	local function pass()
		return client
	end

	return iterate(self[Middleware.client], client, pass)
end

--[=[
	Adds middleware to the server interface.

	@private
	@param middlewareArray {[Middleware]}
]=]

function ServerInterface:extend(middlewareArray)
	table.sort(middlewareArray, function(a, b)
		local aPriority = a._priority or Middleware.priority.normal
		local bPriority = b._priority or Middleware.priority.normal

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
	Creates a new server middleware interface.

	@param netType [NetTypes.NetType]
	@return ServerInterface
]=]

function ServerInterface.new(netType)
	return setmetatable({ _netType = netType }, ServerInterface)
end

return ServerInterface
