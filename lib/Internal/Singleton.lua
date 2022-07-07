local Internal = script.Parent
local Util = Internal.Util

local Symbol = require(Util.Symbol)
local TableUtil = require(Util.TableUtil)

local STRICT_WRITE_ERROR = "Cannot assign property '%s' to read-only table '%s'."
local SINGLETON_NOT_FOUND = "Singleton by the name of '%s' was not found."

--[=[
	A singleton is an onject that can only be instantiated once.
	This class is used to construct a singleton object.

	@class Singleton
	@__index get
]=]

--[=[
	@interface definedKey
    @within Singleton
]=]

--[=[
    @interface SingletonDefinition
    @within Singleton
    .[definedKey] boolean -- Whether the singleton has been defined.
]=]

local definedKey = Symbol("defined")

local shallowDefinitions = {}

--[=[
	Creates a new singleton.
	[definedKey] is used at the end of Sharp initialization to determine if the singleton has been defined,
	if not an error will be thrown.

    @private
    @within Singleton
    @param name string
    @return [SingletonDefinition]
]=]

local function createShallowDefinition(name)
    local definition = { [definedKey] = false }
    shallowDefinitions[name] = definition
    return definition
end

--[=[
	Gets the singleton instance of the specified name.

	@within Singleton
	@param name string
	@return [SingletonDefinition]
]=]

local function get(name)
    return shallowDefinitions[name] or createShallowDefinition(name)
end

--[=[
	Define function is used to construct a singleton object.
	If singleton is already constructed, the data will be merged with the [SingletonDefinition].

	@within Singleton
    @param name string
	@param definition {}?
	@return [SingletonDefinition]
]=]

local function define(name, definition)
    local singleton = shallowDefinitions[name]

    if singleton == nil then
        singleton = definition or {}
        shallowDefinitions[name] = singleton
    elseif definition then
        singleton = TableUtil.Dictionary.merge(singleton, definition)
    end

    singleton[definedKey] = true

    return singleton
end

--[=[
	Called at the end of Sharp initialization to check if all singletons have been defined.
	If not, an error will be thrown.

	@private
	@within Singleton
]=]

local function _onLifeCycleComplete()
    for name, definition in shallowDefinitions do
        if definition[definedKey] == false then
            warn(SINGLETON_NOT_FOUND:format(name))
        end
    end
end

return setmetatable({
	define = define,
	_onLifeCycleComplete = _onLifeCycleComplete,
}, {
	__index = function(_, key)
		return get(key)
	end,

	__newindex = function(_, key)
		error(STRICT_WRITE_ERROR:format(key, "Singleton"))
	end,
})
