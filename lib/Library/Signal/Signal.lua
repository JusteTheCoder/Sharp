--[[
	This is a Signal class which has effectively identical behavior to a
	normal RBXScriptSignal, with the only difference being a couple extra
	stack frames at the bottom of the stack trace when an error is thrown.
	This implementation caches runner coroutines, so the ability to yield in
	the signal handlers comes at minimal extra cost over a naive signal
	implementation that either always or never spawns a thread.
]]

-- The currently idle thread to run the next handler on
local freeRunnerThread = nil

--[[
	Function which acquires the currently idle handler runner thread, runs the
	function fn on it, and then releases the thread, returning it to being the
	currently idle one.
	If there was a currently idle runner thread already, that's okay, that old
	one will just get thrown and eventually GCed.
]]

local function acquireRunnerThreadAndCallEventHandler(fn, ...)
	local acquiredRunnerThread = freeRunnerThread
	freeRunnerThread = nil
	fn(...)
	-- The handler finished running, this runner thread is free again.
	freeRunnerThread = acquiredRunnerThread
end

--[[
	Coroutine runner that we create coroutines of. The coroutine can be
	repeatedly resumed with functions to run followed by the argument to run
	them with.
]]

local function runEventHandlerInFreeThread(...)
	acquireRunnerThreadAndCallEventHandler(...)
	while true do
		acquireRunnerThreadAndCallEventHandler(coroutine.yield())
	end
end

--[=[
	A connection is a object linked to a signal.

	@class Connection
]=]

local Connection = {}
Connection.__index = Connection

--[=[
	Creates a new connection.

	@private
	@param signal Signal
	@param fn (...: any?) -> ()

	@return Connection
]=]

function Connection.new(signal, fn)
	return setmetatable({
		_connected = true,
		_signal = signal,
		_fn = fn,
		_next = false,
	}, Connection)
end

--[=[
	Disconnects the connection.
]=]

function Connection:Disconnect()
	assert(self._connected, "Can't disconnect a connection twice.", 2)
	self._connected = false

	-- Unhook the node, but DON'T clear it. That way any fire calls that are
	-- currently sitting on this node will be able to iterate forwards off of
	-- it, but any subsequent fire calls will not hit it, and it will be GCed
	-- when no more fire calls are sitting on it.
	if self._signal._handlerListHead == self then
		self._signal._handlerListHead = self._next
	else
		local prev = self._signal._handlerListHead
		while prev and prev._next ~= self do
			prev = prev._next
		end
		if prev then
			prev._next = self._next
		end
	end
end

Connection.disconnect = Connection.Disconnect

table.freeze(Connection)

--[=[
	A signal is an object which can be connected to and fired.

	@class Signal
]=]

local Signal = {}
Signal.__index = Signal

--[=[
	Creates a new signal.

	@return Signal
]=]

function Signal.new()
	return setmetatable({
		_handlerListHead = false,
	}, Signal)
end

--[=[
	Creates a new signal from RBXScriptSignal.

	@param RBXScriptSignal RBXScriptSignal

	@return Signal
]=]

function Signal.Wrap(RBXScriptSignal)
	local signal = setmetatable({
		_handlerListHead = false,
	}, Signal)

	signal._rbxScriptSignal = RBXScriptSignal:Connect(function(...)
		local item = signal._handlerListHead
		while item do
			if item._connected then
				if not freeRunnerThread then
					freeRunnerThread = coroutine.create(runEventHandlerInFreeThread)
				end
				task.spawn(freeRunnerThread, item._fn, ...)
			end
			item = item._next
		end
	end)

	return signal
end

--[=[
	Connects a function to the signal, which will be called
	when the signal fires.

	@param fn (...: any) -> ()
	@return Connection
]=]

function Signal:Connect(fn)
	local connection = Connection.new(self, fn)
	if self._handlerListHead then
		connection._next = self._handlerListHead
		self._handlerListHead = connection
	else
		self._handlerListHead = connection
	end
	return connection
end

--[=[
	Connects a function to the signal, which will be called
	the next time the signal fires. Once the connection is triggered, it will disconnect itself.

	@param fn (...: any) -> ()
	@return Connection
]=]

function Signal:Once(fn)
	local connection
	connection = Connection.new(self, function(...)
		connection:Disconnect()
		fn(...)
	end)
	if self._handlerListHead then
		connection._next = self._handlerListHead
		self._handlerListHead = connection
	else
		self._handlerListHead = connection
	end
	return connection
end

--[=[
	Disconnects all handlers from handlers. Since we use a linked list it suffices
	to clear the reference to the head handler.
]=]

function Signal:DisconnectAll()
	self._handlerListHead = false
end

--[=[
	Signal:Fire(...) implemented by running the handler functions on the
	coRunnerThread, and any time the resulting thread yielded without returning
	to us, that means that it yielded to the Roblox scheduler and has been taken
	over by Roblox scheduling, meaning we have to make a new coroutine runner.

	@param ... any
]=]

function Signal:Fire(...)
	local item = self._handlerListHead
	while item do
		if item._connected then
			if not freeRunnerThread then
				freeRunnerThread = coroutine.create(runEventHandlerInFreeThread)
			end
			task.spawn(freeRunnerThread, item._fn, ...)
		end
		item = item._next
	end
end

--[=[
	Implement Signal:Wait() in terms of a temporary connection using
	a Signal:Connect() which disconnects itself.

	@yields
]=]

function Signal:Wait()
	local waitingCoroutine = coroutine.running()
	local cn
	cn = self:Connect(function(...)
		cn:Disconnect()
		task.spawn(waitingCoroutine, ...)
	end)
	return coroutine.yield()
end

--[=[
	Destroys the signal, disconnecting all handlers and disposing of the
	RBXScriptSignal.

	:::tip

	Keep in mind there's no reason to destroy a signal unless it is constructed
	with [Signal.Wrap]. In other cases, the signal will be garbage collected if all
	references to it are lost.

	:::
]=]

function Signal:Destroy()
	self._handlerListHead = false

	if self._rbxScriptSignal then
		self._rbxScriptSignal:Disconnect()
		self._rbxScriptSignal = nil
	end
end

-- I'm not a huge fan of aliases in general,
-- but I chose PascalCase for the methods to keep the Signal API consistent
-- with RBXScriptSignals, which is conflicting with the rest of the API.
-- As a result, I've created aliases for the methods to combat this.
Signal.wrap = Signal.Wrap
Signal.connect = Signal.Connect
Signal.once = Signal.Once
Signal.disconnectAll = Signal.DisconnectAll
Signal.fire = Signal.Fire
Signal.wait = Signal.Wait
Signal.destroy = Signal.Destroy

table.freeze(Signal)
return Signal
