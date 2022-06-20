local Sharp = _G.Sharp

--[=[
	An event which can be listened to and fired.

	@class ServerAsyncEvent
]=]

local Signal = Sharp.library.Signal
local Promise = Sharp.library.Promise

local ServerInterface = Sharp.package.Net.ServerInterface
local Objects = Sharp.package.Net.Objects

local ServerAsyncEvent = {}
ServerAsyncEvent.__index = ServerAsyncEvent

--[=[
	Constructs the internals of the event.

	@private
	@param bridge string
	@param name string
	@return [Promise]
]=]

function ServerAsyncEvent:_implement(bridge, name)
	return Objects.getFunctionAsync(bridge, name):andThen(function(instance)
		self._instance = instance
		self._name = name
	end)
end

--[=[
	Listen for an event. Connects to signal object
	instead of the event to preserve performance while
	processing middleware.

	@param callback function
]=]

function ServerAsyncEvent:respond(callback)
	callback = Promise.promisify(callback)

	self._instance.OnServerInvoke = function(client, ...)
		local status, result = self.middleware:processResult(client, ...)

		if status == false then
			warn("[Net] %s", result)
			return false, result
		end

		return callback(client, table.unpack(result))
			:catch(function(err)
				warn("[Net] %s", err)
			end)
			:await()
	end
end

--[=[
	Extend the event with middleware.

	@param middleware {[Middleware]}
]=]

function ServerAsyncEvent:extend(middleware)
	self._middleware:extend(middleware)
	return self
end

--[=[
	Constructs a new event.

	@return ServerAsyncEvent
]=]

function ServerAsyncEvent.new()
	local self = {
		_name = "ServerAsyncEvent",
		_instance = nil,
		_listener = Signal.new(),
	}
	self._middleware = ServerInterface.new(self)

	return setmetatable(self, ServerAsyncEvent)
end

return ServerAsyncEvent.new
