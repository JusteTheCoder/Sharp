local Sharp = _G.Sharp

local Promise = Sharp.Library.Promise

local FAILED_TO_FIND_INSTANCE = "Failed to find instance '%s' in '%s'."
local ROOT_NAME = "_net"
local TIMEOUT = 5

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local isServer = RunService:IsServer()
local rootFolder

--[=[
	Handles instances for the Net library.

	@private
	@class NetObject
]=]

--[=[
	Create a new instance and returns a promise.

	@private
	@within NetObject
	@param parent Instance
	@param name string
	@param class string?
	@return [Promise]
]=]

local function promiseCreate(parent, name, class)
	return Promise.new(function(resolve)
		local instance = Instance.new(class)
		instance.Name = name
		instance.Parent = parent

		resolve(instance)
	end)
end

--[=[
	Wait for an instance to be ready.
    Error if it doesn't exist after a certain amount of time.

	@private
	@within NetObject
	@param parent Instance
	@param name string
	@param class string?
	@return [Promise]
]=]

local function promiseWait(parent, name, class)
	return Promise.fromEvent(parent, "ChildAdded", function(child)
		return child.Name == name and child:IsA(class)
	end):timeout(TIMEOUT, string.format(FAILED_TO_FIND_INSTANCE, name, parent.Name))
end

--[=[
	Return a promise that resolves when an object is ready.

	@private
	@within NetObject
	@param parent Instance
	@param name string
	@param class string?
	@return [Promise]
]=]

local function promiseInstance(parent, name, class)
	class = class or "Folder"

	local instance = parent:FindFirstChild(name)
	if instance then
		return Promise.resolve(instance)
	end

	return isServer and promiseCreate(parent, name, class) or promiseWait(parent, name, class)
end

--[=[
	Return a promise that resolves when the root folder is ready.

	@private
	@within NetObject
	@return [Promise]
]=]

local function getRootAsync()
	return rootFolder and Promise.resolve(rootFolder)
		or promiseInstance(ReplicatedStorage, ROOT_NAME):andThen(function(root)
			rootFolder = root
			return root
		end)
end

--[=[
	Return a promise that resolves when a bridge folder is ready.

	@private
	@within NetObject
	@param name string
	@return [Promise]
]=]

local function getBridgeAsync(name)
	return getRootAsync():andThen(function(root)
		return promiseInstance(root, name)
	end)
end

--[=[
	Return a promise that resolves when an netType is ready.

	@private
	@within NetObject
	@param bridgeId string
	@param name string
    @param class string?
	@return [Promise]
]=]

local function promiseNetType(bridgeId, name, class)
	return getBridgeAsync(bridgeId):andThen(function(bridge)
		return promiseInstance(bridge, name, class)
	end)
end

--[=[
    Returns all netTypes in a bridge.

    @private
    @within NetObject
    @param bridgeId string
    @return [Promise]
]=]

local function getNetTypesInBridge(bridgeId)
	return getBridgeAsync(bridgeId):andThen(function(bridge)
		return bridge:GetChildren()
	end)
end

return {
	promiseInstance = promiseInstance,
	promiseNetType = promiseNetType,
	getRootAsync = getRootAsync,
	getBridgeAsync = getBridgeAsync,
	getNetTypesInBridge = getNetTypesInBridge,
}
