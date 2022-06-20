local Sharp = _G.Sharp

--[=[
	A network library designed to be used in conjunction with the Sharp framework.

	@class Net
]=]

local function give(t, netTypes)
	for typeName, netType in netTypes do
		netType:_implement(t._bridgeId, typeName)
		t.net[typeName] = netType
	end

	return t
end

--[=[
	Accepts a table with _bridgeId and extends its functionality with networking.
	Use give method to add netTypes to the object.

	@within Net
	@param t {any: any}

	@return t
]=]

local function from(t)
	local bridgeId = t._bridgeId

	if bridgeId == nil then
		error("[Net] BridgeId is nil", 2)
		return
	end

	t.give = give
	t.net = {}

	return t
end

--[=[
	Takes a dictionary of netTypes and a bridgeId and implements the netTypes.

	@within Net
	@param bridgeId string
	@param netTypes {string: netType}
]=]

local function now(bridgeId, netTypes)
	for typeName, netType in netTypes do
		netType:_implement(bridgeId, typeName)
	end

	return netTypes
end

return table.freeze({
	from = from,
	now = now,

	types = Sharp.package.Net.Types,
	middleware = Sharp.package.Net.Middleware,
})