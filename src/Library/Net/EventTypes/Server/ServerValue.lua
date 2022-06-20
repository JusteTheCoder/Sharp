local Players = game:GetService("Players")
local Sharp = _G.Sharp

--[=[
	ServerValue

	@class ServerValue
]=]

local Signal = Sharp.library.Signal

local ServerInterface = Sharp.package.Net.ServerInterface
local Objects = Sharp.package.Net.Objects

local ServerValue = {}
ServerValue.__index = ServerValue

--[=[
	Constructs the internals of the event.

	@private
	@param bridge string
	@param name string
	@return [Promise]
]=]

function ServerValue:_implement(bridge, name)
	return Objects.getEventAsync(bridge, name):andThen(function(instance)
		self._instance = instance
		self._name = name

		Players.PlayerAdded:Connect(function(player)
			local _, args = self._middleware:processArgument(self._value)
			self._instance:FireClient(player, table.unpack(args))
		end)
	end)
end

--[=[
	Sets the value.

	@param value any
]=]

function ServerValue:set(value)
	assert(self._instance, "[Net] Event has not been implemented.")
	if self._value == value then
		return
	end

	self._value = value
	self._listener:fire(value)

	local _, args = self._middleware:processArgument(value)
	self._instance:FireAllClients(table.unpack(args))
end

--[=[
	Get the current value.

	@return any
]=]

function ServerValue:get()
	return self._value
end

--[=[
	Listen for changes to the value.

	@param callback function
]=]

function ServerValue:changed(callback)
	return self._listener:connect(callback)
end

--[=[
	Extend the event with middleware.

	@param middleware {[Middleware]}
]=]

function ServerValue:extend(middleware)
	self._middleware:extend(middleware)
	return self
end

--[=[
	Constructs a new event.

	@return ServerValue
]=]

function ServerValue.new()
	local self = {
		_name = "ServerValue",
		_instance = nil,
		_value = nil,
		_listener = Signal.new(),
	}
	self._middleware = ServerInterface.new(self)

	return setmetatable(self, ServerValue)
end

return ServerValue.new
