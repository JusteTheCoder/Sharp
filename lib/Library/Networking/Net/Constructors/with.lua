local Sharp = _G.Sharp

local NetPackage = Sharp.Package.Net
local use = NetPackage.use

--[=[
    Same as use except creates a singleton object.

    @within Ne
    @param bridgeId string
    @param source {any: any}?

    @return {any: any}?
]=]

local function with(bridgeId, targetTable)
    return use(bridgeId, Sharp.Singleton.define(bridgeId, targetTable))
end

return with