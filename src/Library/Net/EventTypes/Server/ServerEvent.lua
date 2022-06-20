local Sharp = _G.Sharp

--[=[
	An event which can be listened to and fired.

	@class ServerEvent
]=]

local Signal = Sharp.library.Signal
local Logger = Sharp.library.Logger

local ServerInterface = Sharp.package.Net.ServerInterface
local Objects = Sharp.package.Net.Objects

local Players = game:GetService("Players")

local ServerEvent = {}
ServerEvent.__index = ServerEvent

--[=[
	Constructs the internals of the event.

	@private
	@param bridge string
	@param name string
	@return [Promise]
]=]

function ServerEvent:_implement(bridge, name)
	return Objects.getEventAsync(bridge, name):andThen(function(instance)
		self._instance = instance
		self._name = name

		-- Since an event might have several listeners,
		-- we use an extra signal that processes middleware to retain performance.
		-- Also enables us to use event caching for all listeners.
		self._instance.OnServerEvent:Connect(function(...)
			local status, result = self:processResult(...)

			if status == false then
				return warn("[Net] %s", result)
			end

			return self._listener:fire(table.unpack(result))
		end)
	end)
end

--[[
	Send an event to a client.

	@param client
		The client to send the event to.
	@param ...
		The arguments to send.

	@return void
]]

function ServerEvent:send(client, ...)
	assert(self._instance, "[Net] Event has not been implemented.")
	local status = self._middleware:processClient(client)

	if status == false then
		Logger.debugWarn(
			"[Net] Event '%s' was not sent to client '%s' because it was filtered.",
			self._name,
			client.Name
		)
		return
	end

	local _, args = self._middleware:processArgument(...)
	self._instance:FireClient(client, table.unpack(args))
end

--[[
	Send an event to a list of clients.

	@param clients
		The clients to send the event to.
	@param ...
		The arguments to send.

	@return void
]]

function ServerEvent:sendTo(clients, ...)
	assert(self._instance, "[Net] Event has not been implemented.")
	local _, args = self._middleware:processArgument(...)

	for _, client in clients do
		local status = self._middleware:processClient(client)

		if status == false then
			Logger.debugWarn(
				"[Net] Event '%s' was not sent to client '%s' because it was filtered.",
				self._name,
				client.Name
			)
			continue
		end

		self._instance:FireClient(client, table.unpack(args))
	end
end

--[[
	Send an event to all clients.

	@param ...
		The arguments to send.

	@return void
]]

function ServerEvent:sendToAll(...)
	assert(self._instance, "[Net] Event has not been implemented.")
	local _, args = self._middleware:processArgument(...)

	for _, client in Players:GetPlayers() do
		local status = self._middleware:processClient(client)

		if status == false then
			Logger.debugWarn(
				"[Net] Event '%s' was not sent to client '%s' because it was filtered.",
				self._name,
				client.Name
			)
			continue
		end

		self._instance:FireClient(client, table.unpack(args))
	end
end

--[[
	Send an event to all clients except a list of clients.

	@param clients
		The clients to exclude from the event.
	@param ...
		The arguments to send.

	@return void
]]

function ServerEvent:sendToOthers(clients, ...)
	assert(self._instance, "[Net] Event has not been implemented.")
	local _, args = self._middleware:processArgument(...)

	for _, client in Players:GetPlayers() do
		if table.find(clients, client) then
			continue
		end

		local status = self._middleware:processClient(client)

		if status == false then
			Logger.debugWarn(
				"[Net] Event '%s' was not sent to client '%s' because it was filtered.",
				self._name,
				client.Name
			)
			continue
		end

		self._instance:FireClient(client, table.unpack(args))
	end
end

--[=[
	Listen for an event. Connects to signal object
	instead of the event to preserve performance while
	processing middleware.

	@param callback function
]=]

function ServerEvent:receive(callback)
	return self._listener:connect(callback)
end

--[=[
	Extend the event with middleware.

	@param middleware {[Middleware]}
]=]

function ServerEvent:extend(middleware)
	self._middleware:extend(middleware)
	return self
end

--[=[
	Constructs a new event.

	@return ServerEvent
]=]

function ServerEvent.new()
	local self = {
		_name = "ServerEvent",
		_instance = nil,
		_listener = Signal.new(),
	}
	self._middleware = ServerInterface.new(self)

	return setmetatable(self, ServerEvent)
end

return ServerEvent.new
