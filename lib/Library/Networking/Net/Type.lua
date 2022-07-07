local NetPackage = _G.Sharp.Package.Net

local RunService = game:GetService("RunService")
local isClient = RunService:IsClient()

--[=[
	Event types for net.
	@class Net
]=]

return {
	event = isClient and NetPackage.ClientEvent or NetPackage.ServerEvent,
	asyncEvent = isClient and NetPackage.ClientAsyncEvent or NetPackage.ServerAsyncEvent,
}
