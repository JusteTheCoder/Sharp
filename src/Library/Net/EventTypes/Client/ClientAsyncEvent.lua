local Sharp = _G.Sharp

--[=[
	An event which can be listened to and fired.

	@class ClientAsyncEvent
]=]

local Promise = Sharp.library.Promise

local ClientInterface = Sharp.package.Net.ClientInterface
local Objects = Sharp.package.Net.Objects

local ClientAsyncEvent = {}
ClientAsyncEvent.__index = ClientAsyncEvent

--[=[
	Constructs the internals of the event.

	@private
	@param bridge string
	@param name string
	@return [Promise]
]=]

function ClientAsyncEvent:_implement(bridge, name)
	return Objects.getFunctionAsync(bridge, name):andThen(function(instance)
		self._instance = instance
		self._name = name
	end)
end

--[=[
	Sets a timeout for the call function.

	@param timeout number
	@return self
]=]

function ClientAsyncEvent:setTimeout(timeout)
	self._timeout = timeout
	return self
end

--[=[
	Call the server and return a promise.

	@param ... any
	@return Promise
]=]

function ClientAsyncEvent:call(...)
	assert(self._instance, "[Net] Event has not been implemented.")

	local status, args = self._middleware:processArgument(...)
	if not status then
		return Promise.reject(args)
	end

	return Promise.try(self._instance.InvokeServer, self._instance, table.unpack(args))
		:timeout(self._timeout, "Timeout calling " .. self._name)
		:andThen(function(success, ...)
			if success == false then
				return Promise.reject(...)
			end

			local _, result = self._middleware:processResult(...)
			return Promise.resolve(table.unpack(result))
		end)
		:catch(function(err)
			warn("[Net] %s", err)
		end)
end

--[=[
	Add middleware to the event.

	@param middleware {[Middleware]}
	@return self
]=]

function ClientAsyncEvent:extend(middleware)
	self._middleware:extend(middleware)
	return self
end

--[=[
	Create a new ClientAsyncEvent.

	@return ClientAsyncEvent
]=]

function ClientAsyncEvent.new()
	local self = {
		_name = "ClientAsyncEvent",
		_instance = nil,
		_timeout = 10,
	}
	self._middleware = ClientInterface.new(self)

	return setmetatable(self, ClientAsyncEvent)
end

return ClientAsyncEvent.new
