--[=[
	A singleton is an onject that can only be instantiated once.
	This class is used to construct a singleton object.

	@class Singleton
	@__index get
]=]

--[=[
	Used to define a singleton.
	@interface SingletonDefinition
	@within Singleton
	.name string -- The name of the singleton.
	.[start] () -> ()
	.[init] () -> ()
	.[any] any
]=]

--[=[
	@interface LiveSingleton
	@within Singleton
	._defined boolean -- Whether the singleton has been adopted.
	.[any] any
]=]

local NO_NAME_SPECIFIED = "No name specified for type '%s'."
local STRICT_WRITE_ERROR = "Cannot assign property '%s' to read-only table '%s'."
local SINGLETON_NOT_FOUND = "Singleton by the name of '%s' was not found."

local Internal = script.Parent
local Logger = require(Internal.Utility.Logger)
local Table = require(Internal.Utility.Table)

local singletonStore = {}

--[[
	Creates a new singleton.
	_defined is used at the end of Sharp initialization to determine if the singleton has been defined,
	if not an error will be thrown.
]]

local function createSingleton(name)
	local singleton = { _defined = false }
	singletonStore[name] = singleton
	return singleton
end

--[=[
	Gets the singleton instance of the specified name.

	@within Singleton
	@param name string

	@return liveSingleton
]=]

local function get(name)
	return singletonStore[name] or createSingleton(name)
end

--[=[
	Create function is used to construct a singleton object.
	If singleton is already constructed, the SingletonDefinition will be merged with the previously constructed singleton.

	@within Singleton
	@param singletonDefinition SingletonDefinition'
	@return singleton LiveSingleton
]=]

local function create(singletonDefinition)
	local name = singletonDefinition.name

	if name == nil then
		Logger.logError(2, NO_NAME_SPECIFIED, "Singleton")
	end

	local singleton = singletonStore[name]

	if singleton == nil then
		singleton = singletonDefinition
		singletonStore[name] = singleton
	else
		Table.dictionary.merge(singleton, singletonDefinition)
	end

	singleton._defined = true

	return singleton
end

--[=[
	Called at the end of Sharp initialization to check if all singletons have been defined.
	If not, an error will be thrown.

	@private
	@within Singleton
]=]

local function endRunCycle()
	for name, singleton in singletonStore do
		if not singleton._defined then
			Logger.logError(SINGLETON_NOT_FOUND, name)
		end
	end
end

return setmetatable({
	create = create,
	_endRunCycle = endRunCycle,
}, {
	__index = function(_, key)
		return get(key)
	end,

	__newindex = function(_, key)
		Logger.logError(2, STRICT_WRITE_ERROR, key, "Singleton")
	end,
})
