local Sharp = _G.Sharp

--[=[
	ClientValue

	@class ClientValue
]=]

local Signal = Sharp.library.Signal

local ClientInterface = Sharp.package.Net.ClientInterface
local Objects = Sharp.package.Net.Objects

local ClientValue = {}
ClientValue.__index = ClientValue

--[=[
	Constructs the internals of the event.

	@private
	@param bridge string
	@param name string
	@return [Promise]
]=]

function ClientValue:_implement(bridge, name)
	return Objects.getEventAsync(bridge, name):andThen(function(instance)
		self._instance = instance
		self._name = name

		-- Since an event might have several listeners,
		-- we use an extra signal that processes middleware to retain performance.
		-- Also enables us to use event caching for all listeners.
		self._instance.OnClientValue:Connect(function(value)
			local _, result = self:processResult(value)
			self._value = table.unpack(result)
			self._listener:fire(self._value)
		end)
	end)
end

--[=[
	Get the current value.

	@return any
]=]

function ClientValue:get()
	return self._value
end

--[=[
	Listen for changes to the value.

	@param callback function
]=]

function ClientValue:changed(callback)
	return self._listener:connect(callback)
end

--[=[
	Extend the event with middleware.

	@param middleware {[Middleware]}
]=]

function ClientValue:extend(middleware)
	self._middleware:extend(middleware)
	return self
end

--[=[
	Constructs a new event.

	@return ClientValue
]=]

function ClientValue.new()
	local self = {
		_name = "ClientValue",
		_instance = nil,
		_value = nil,
		_listener = Signal.new(),
	}
	self._middleware = ClientInterface.new(self)

	return setmetatable(self, ClientValue)
end

return ClientValue.new