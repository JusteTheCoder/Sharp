local Sharp = _G.Sharp

local NetPackage = Sharp.Package.Net
local Object = NetPackage.Object

local netTypes = {
	Event = NetPackage.ClientEvent,
	AsyncEvent = NetPackage.ClientAsyncEvent,
}

local function useTrove(bridgeId)
	local remotes = Object.getNetTypesInBridge(bridgeId):expect()
	local types = {}

	for _, remote in ipairs(remotes) do
		local netType = remote:GetAttribute("_netType")
		types[remote.Name] = netTypes[netType]()
	end

	return types
end

return useTrove
