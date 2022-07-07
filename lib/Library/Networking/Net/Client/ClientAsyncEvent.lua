local Sharp = _G.Sharp

local Promise = Sharp.Library.Promise
local Signal = Sharp.Library.Signal
local TypeClass = Sharp.Package.Net.TypeClass
local Object = Sharp.Package.Net.Object

local DEFAULT_TIMEOUT = 10
local TIMEOUT_ERROR = "Timeout calling '%s'."

--[=[
	An event which can be called on a clien to return
    a value from the server.

	@class ClientAsyncEvent
]=]

local ClientAsyncEvent = setmetatable({}, TypeClass)
ClientAsyncEvent.className = "AsyncEvent"
ClientAsyncEvent.instanceClass = "RemoteFunction"
ClientAsyncEvent.__index = ClientAsyncEvent

--[=[
	Call the server and return a promise.

	@param ... any
	@return Promise
]=]

function ClientAsyncEvent:callServer(...)
	local instance = self._instance
	local args = self._processOutboundMiddleware and { self._processOutboundMiddleware(...) } or { ... }

	return Promise.try(instance.InvokeServer, instance, table.unpack(args))
		:timeout(self._timeout, string.format(TIMEOUT_ERROR, self._name))
		:andThen(function(...)
			if self._processInboundMiddleware then
				return self._processInboundMiddleware(...)
			end

			return ...
		end)
		:catch(warn)
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
	Constructs the internals of the event.

	@private
	@param bridgeId string
	@param name string
	@return [Promise]
]=]

function ClientAsyncEvent:_implement(bridgeId, name)
	return Object.promiseNetType(bridgeId, name, self.instanceClass):andThen(function(instance)
		self._name = name
		self._instance = instance
	end)
end

--[=[
	Create a new ClientAsyncEvent.

	@return ClientAsyncEvent
]=]

function ClientAsyncEvent.new()
	return setmetatable({
		_signal = Signal.new(),
		_instance = nil,
		_processOutboundMiddleware = nil,
		_processInboundMiddleware = nil,
		_timeout = DEFAULT_TIMEOUT,
	}, ClientAsyncEvent)
end

return ClientAsyncEvent.new
