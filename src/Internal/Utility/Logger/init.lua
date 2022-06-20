--[=[
	A library for logging messages to the console.
	Since this library is designed to be used in conjunction with the
	Sharp framework, a "[Sharp] " prefix is added to all messages.

	@class Logger
]=]

local PREFIX = "[Sharp] "
local BLANK_FUNCTION = function() end

local RunService = game:GetService("RunService")

local isStudio = RunService:IsStudio()

local traceSet = {}

--[[
	Adds the Sharp prefix to a message as well as formats it.
]]

local function parseMessage(message, ...)
	return string.format(PREFIX .. message, ...)
end

--[[
	Returns true if it's the first time this function has been called
	for the given source and line.
]]

local function isNewTrace(depth)
	local source, line = debug.info(depth, "sl")
	local trace = source .. ":" .. line

	if traceSet[trace] ~= nil then
		return false
	end

	traceSet[trace] = true

	return true
end

--[[
	If in studio mode returns the given function, otherwise a blank function.
]]

local function getStudioLogger(fn)
	return isStudio and fn or BLANK_FUNCTION
end

--[[
	The first argument can either be a string or a number.
	If it's a string, it's treated as a message.
	If it's a number, it's treated as the depth of the callstack.
	This function returns the message, depth, and arguments.
]]

local function processArgs(arg, ...)
	local depth = 3
	local args

	if type(arg) == "number" then
		depth, arg = arg + 2, ...
		args = { select(2, ...) }
	else
		args = { ... }
	end

	return arg, depth, args
end

--[=[
	Logs a message to the console.

	```lua
	Logger.log("Hello, %s!", "world") -- [Sharp] Hello, world!
	Logger.log("Hello, world!") -- [Sharp] Hello, world!
	```

	@within Logger
	@param message string
	@param ... string | number -- Arguments to format the message with.
]=]

local function log(message, ...)
	print(parseMessage(message, ...))
end

--[=[
	Logs a message to the console if in studio mode.

	@within Logger
	@function logStudio
	@param message string
	@param ... string | number -- Arguments to format the message with.
]=]

local logStudio = getStudioLogger(log)

--[=[
	Logs a message to the console if first time called for the given source and line.
	If the first argument is a number, it's treated as the depth of the callstack.
	And the second argument as the message.

	@within Logger
	@param message string | number
	@param ... string | number -- Arguments to format the message with.
]=]

local function logTrace(message, ...)
	local arg, depth, args = processArgs(message, ...)

	if isNewTrace(depth) then
		log(arg, table.unpack(args))
	end
end

-- Add similar functions for warning and error. As well as a assert function.

--[=[
	Logs a warning to the console.

	```lua
	Logger.warn("Hello, %s!", "world") -- [Sharp] Warning: Hello, world!
	Logger.warn("Hello, world!") -- [Sharp] Warning: Hello, world!
	```

	@within Logger
	@param message string
	@param ... string | number -- Arguments to format the message with.
]=]

local function logWarn(message, ...)
	warn(parseMessage(message, ...))
end

--[=[
	Creates a warning if in studio mode.

	@within Logger
	@function warnStudio
	@param message string
	@param ... string | number -- Arguments to format the message with.
]=]

local warnStudio = getStudioLogger(logWarn)

--[=[
	Creates a warning if first time called for the given source and line.
	If the first argument is a number, it's treated as the depth of the callstack.
	And the second argument as the message.

	@within Logger
	@param message string | number
	@param ... string | number -- Arguments to format the message with.
]=]

local function warnTrace(message, ...)
	local arg, depth, args = processArgs(message, ...)

	if isNewTrace(depth) then
		logWarn(arg, table.unpack(args))
	end
end

--[=[
	Logs an error to the console.
	If the first argument is a number, it's treated as the depth of the callstack.

	```lua
	Logger.error("Hello, %s!", "world") -- [Sharp] Error: Hello, world!
	Logger.error("Hello, world!") -- [Sharp] Error: Hello, world!
	```

	@within Logger
	@param message string | number
	@param ... string | number -- Arguments to format the message with.
]=]

local function logError(message, ...)
	local arg, depth, args = processArgs(message, ...)
	error(parseMessage(arg, table.unpack(args)), depth)
end

--[=[
	Errors if condition is false.
	If the first argument is a number, it's treated as the depth of the callstack.

	```lua
	Logger.assert(true, "Hello, %s!", "world") -- Nothing happens.
	Logger.assert(false, "Hello, %s!", "world") -- Error: [Sharp ]Hello, world!
	```

	@within Logger
	@param condition T
	@param message string | number
	@param ... string | number -- Arguments to format the message with.

	@return T
]=]

local function logAssert(condition, message, ...)
	return condition or logError(message, ...)
end

return table.freeze({
	log = log,
	logTrace = logTrace,
	logStudio = logStudio,
	logWarn = logWarn,
	warnStudio = warnStudio,
	warnTrace = warnTrace,
	logError = logError,
	assert = logAssert,
})
