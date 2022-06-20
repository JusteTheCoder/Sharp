local Sharp = _G.Sharp

--[=[
	Handles instances for the Net library.

	@private
	@class NetObject
]=]

local OBJECT_TIMEOUT = 5

local Promise = Sharp.library.Promise

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local isServer = RunService:IsServer()
local netFolder

--[=[
	Return a promise that resolves when an object is ready.

	@private
	@within NetObject
	@param parent Instance
	@param name string
	@param class string?

	@return [Promise]
]=]

local function promiseObject(parent, name, class)
	class = class or "Folder"
	local object = parent:FindFirstChild(name)

	if object then
		return Promise.resolve(object)
	end

	return isServer
			and Promise.new(function(resolve)
				object = Instance.new(class)
				object.Name = name
				object.Parent = parent

				resolve(object)
			end)
		or Promise.fromEvent(parent, "ChildAdded", function(child)
			return child.Name == name and child:IsA(class)
		end):timeout(OBJECT_TIMEOUT, "Failed to find object " .. name .. " in " .. parent.Name)
end

--[=[
	Return a promise that resolves when the root folder is ready.

	@private
	@within NetObject
	@return [Promise]
]=]

local function getRootAsync()
	return netFolder and Promise.resolve(netFolder) or promiseObject(ReplicatedStorage, "Net")
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
		return promiseObject(root, name)
	end)
end

--[=[
	Return a promise that resolves when an event is ready.

	@private
	@within NetObject
	@param bridgeId string
	@param name string

	@return [Promise]
]=]

local function getEventAsync(bridgeId, name)
	return getBridgeAsync(bridgeId)
		:andThen(function(bridge)
			return promiseObject(bridge, name, "RemoteEvent")
		end)
		:catch(function(err)
			warn("[Net] %s", err)
		end)
end

--[=[
	Return a promise that resolves when a function is ready.

	@private
	@within NetObject
	@param bridgeId string
	@param name string

	@return [Promise]
]=]

local function getFunctionAsync(bridgeId, name)
	return getBridgeAsync(bridgeId)
		:andThen(function(bridge)
			return promiseObject(bridge, name, "RemoteFunction")
		end)
		:catch(function(err)
			warn("[Net] %s", err)
		end)
end

return table.freeze({
	getEventAsync = getEventAsync,
	getFunctionAsync = getFunctionAsync,
})
