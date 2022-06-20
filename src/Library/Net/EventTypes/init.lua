local Sharp = _G.Sharp

--[=[
	Different event types for net.
	@class NetTypes
]=]

--[=[
	@interface NetType
	@within NetTypes
	._name string
	._instance Instance
]=]

local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()

return table.freeze({
	event = isServer and Sharp.package.Net.ServerEvent or Sharp.package.Net.ClientEvent,
	asyncEvent = isServer and Sharp.package.Net.ServerAsyncEvent or Sharp.package.Net.ClientAsyncEvent,
	value = isServer and Sharp.package.Net.ServerValue or Sharp.package.Net.ClientValue,
})
