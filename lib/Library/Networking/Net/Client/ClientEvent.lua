local Sharp = _G.Sharp

local Signal = Sharp.Library.Signal
local TypeClass = Sharp.Package.Net.TypeClass
local Object = Sharp.Package.Net.Object

--[=[
	An event which can be listened to and fired.

	@class ClientEvent
]=]

local ClientEvent = setmetatable({}, TypeClass)
ClientEvent.className = "Event"
ClientEvent.instanceClass = "RemoteEvent"
ClientEvent.__index = ClientEvent

--[=[
	Send an event to the server.

	@param ... any
]=]

function ClientEvent:sendToServer(...)
	if self._processCallFunction then
		self._instance:FireClient(self._processCallFunction(...))
	else
		self._instance:FireClient(...)
	end
end

--[=[
	Constructs the internals of the event.

	@private
	@param bridge string
	@param name string
	@return [Promise]
]=]

function ClientEvent:_implement(bridgeId, name)
	return Object.promiseNetType(bridgeId, name, self.instanceClass):andThen(function(instance)
		self._name = name
		self._instance = instance

        self._instance.OnClientEvent:Connect(function(...)
            if self._processReceiveFunction then
                self._signal:fire(self:_processReceiveFunction(...))
            else
                self._signal:fire(...)
            end
        end)
	end)
end

--[=[
	Constructs a new event.

	@return ClientEvent
]=]

function ClientEvent.new()
	return setmetatable({
		_signal = Signal.new(),
		_instance = nil,
		_processCallFunction = nil,
		_processReceiveFunction = nil,
	}, ClientEvent)
end

return ClientEvent.new
