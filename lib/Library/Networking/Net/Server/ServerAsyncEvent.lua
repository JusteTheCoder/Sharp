local Sharp = _G.Sharp

local Signal = Sharp.Library.Signal
local TypeClass = Sharp.Package.Net.TypeClass
local Object = Sharp.Package.Net.Object

local NO_CALLBACK_ERROR = "No callback function specified for '%s'."

--[=[
	An event which can be listened to and fired.

	@class ServerAsyncEvent
]=]

local ServerAsyncEvent = setmetatable({}, TypeClass)
ServerAsyncEvent.className = "AsyncEvent"
ServerAsyncEvent.instanceClass = "RemoteFunction"
ServerAsyncEvent.__index = ServerAsyncEvent

--[=[
	Send an event to a client.

	@param client [Player]
	@param ... any?
]=]

--[=[
	Constructs the internals of the event.

	@private
	@param bridgeId string
	@param name string
	@return [Promise]
]=]

function ServerAsyncEvent:_implement(bridgeId, name)
	return Object.promiseNetType(bridgeId, name, self.instanceClass):andThen(function(instance)
		self._name = name
		self._instance = instance

		self._instance:SetAttribute("_netType", self.className)

		self._instance.OnServerInvoke = function(client, ...)
			local callback = self._callback
			if not callback then
				return warn(NO_CALLBACK_ERROR:format(self._name))
			end

			local status, err = self:_processReceive(client, ...)

			if status == false then
				return warn(err)
			end

			local args
			if self._processReceiveFunction then
				args = table.pack(self:_processReceiveFunction(...))
			else
				args = table.pack(...)
			end

			if self._processCallFunction then
				return self._processCallFunction(callback(client, table.unpack(args, 1, args.n)))
			else
				return callback(client, table.unpack(args, 1, args.n))
			end
		end
	end)
end

--[=[
    Sets a callback.

    @param callback (client, ...) -> any
    @return self
]=]

function ServerAsyncEvent:setCallback(callback)
	self._callback = callback
	return self
end

--[=[
	Constructs a new event.

	@return ServerAsyncEvent
]=]

function ServerAsyncEvent.new()
	return setmetatable({
		_signal = Signal.new(),
		_instance = nil,
		_callback = nil,
		_processCallFunction = nil,
		_processReceiveFunction = nil,
		_receiveMiddleware = nil,
	}, ServerAsyncEvent)
end

return ServerAsyncEvent.new
