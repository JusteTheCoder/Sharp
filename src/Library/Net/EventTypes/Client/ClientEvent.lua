local Sharp = _G.Sharp

--[=[
	An event which can be listened to and fired.

	@class ClientEvent
]=]

local Signal = Sharp.library.Signal

local ClientInterface = Sharp.package.Net.ClientInterface
local Objects = Sharp.package.Net.Objects

local ClientEvent = {}
ClientEvent.__index = ClientEvent

--[=[
	Constructs the internals of the event.

	@private
	@param bridge string
	@param name string
	@return [Promise]
]=]

function ClientEvent:_implement(bridge, name)
	return Objects.getEventAsync(bridge, name):andThen(function(instance)
		self._instance = instance
		self._name = name

		-- Since an event might have several listeners,
		-- we use an extra signal that processes middleware to retain performance.
		-- Also enables us to use event caching for all listeners.
		self._instance.OnClientEvent:Connect(function(...)
			local status, result = self:processResult(...)
			return status and self._listener:fire(table.unpack(result))
		end)
	end)
end

--[=[
	Send an event to the server.

	@param ... any
]=]

function ClientEvent:send(...)
	assert(self._instance, "[Net] Event has not been implemented.")
	local _, result = self:processArgument(...)
	self._instance:FireServer(table.unpack(result))
end

--[=[
	Listen for an event. Connects to signal object
	instead of the event to preserve performance while
	processing middleware.

	@param callback function
]=]

function ClientEvent:receive(callback)
	return self._listener:connect(callback)
end

--[=[
	Extend the event with middleware.

	@param middleware {[Middleware]}
]=]

function ClientEvent:extend(middleware)
	self._middleware:extend(middleware)
	return self
end

--[=[
	Constructs a new event.

	@return ClientEvent
]=]

function ClientEvent.new()
	local self = {
		_name = "ClientEvent",
		_instance = nil,
		_listener = Signal.new(),
	}
	self._middleware = ClientInterface.new(self)

	return setmetatable(self, ClientEvent)
end

return ClientEvent.new