local Sharp = _G.Sharp

local Signal = Sharp.Library.Signal
local TypeClass = Sharp.Package.Net.TypeClass
local Object = Sharp.Package.Net.Object

local Players = game:GetService("Players")

--[=[
	An event which can be listened to and fired.

	@class ServerEvent
]=]

local ServerEvent = setmetatable({}, TypeClass)
ServerEvent.className = "Event"
ServerEvent.instanceClass = "RemoteEvent"
ServerEvent.__index = ServerEvent

--[=[
	Send an event to a client.

	@param client [Player]
	@param ... any?
]=]

function ServerEvent:sendToClient(client, ...)
	local status, err = self:_processCall(client, ...)

	if status == false then
		return warn(err)
	end

	if self._processCallFunction then
		self._instance:FireClient(client, self._processCallFunction(...))
	else
		self._instance:FireClient(client, ...)
	end
end

--[=[
	Send an event to a list of clients.

	@param clientList {[Player]}
	@param ... any?
]=]

function ServerEvent:sendToClients(clientList, ...)
	local args
	if self._processCallFunction then
		args = table.pack(self._processCallFunction(...))
	else
		args = table.pack(...)
	end

	for _, client in ipairs(clientList) do
		local status, err = self:_processCall(client, ...)

		if status == false then
			warn(err)
			continue
		end

		self._instance:FireClient(client, table.unpack(args, 1, args.n))
	end
end

--[=[
	Send an event to all clients except to a list of clients.

	@param blacklist {[Player]}
	@param ... any?
]=]

function ServerEvent:sendToClientsExcept(blacklist, ...)
	local clients = Players:GetPlayers()

	for _, client in ipairs(blacklist) do
		table.remove(clients, table.find(clients, client))
	end

	self:sendToClients(clients, ...)
end

--[=[
	Send an event to all clients.

	@param ... any?
]=]

function ServerEvent:sendToAllClients(...)
	self:sendToClients(Players:GetPlayers(), ...)
end

--[=[
	Constructs the internals of the event.

	@private
	@param bridgeId string
	@param name string
	@return [Promise]
]=]

function ServerEvent:_implement(bridgeId, name)
	return Object.promiseNetType(bridgeId, name, self.instanceClass):andThen(function(instance)
		self._name = name
		self._instance = instance

		self._instance:SetAttribute("_netType", self.className)

        self._instance.OnServerEvent:Connect(function(client, ...)
			local status, err = self:_processReceive(client, ...)

			if status == false then
				return warn(err)
			end

			if self._processReceiveFunction then
				self._signal:fire(client, self:_processReceiveFunction(...))
			else
				self._signal:fire(client, ...)
			end
        end)
	end)
end

--[=[
	Constructs a new event.

	@return ServerEvent
]=]

function ServerEvent.new()
	return setmetatable({
		_signal = Signal.new(),
		_instance = nil,
		_processCallFunction = nil,
		_processReceiveFunction = nil,
		_callMiddleware = nil,
		_receiveMiddleware = nil,
	}, ServerEvent)
end

return ServerEvent.new
