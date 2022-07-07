local Sharp = _G.Sharp

local NetPackage = Sharp.Package.Net
local Trove = NetPackage.Trove
local useTrove = NetPackage.useTrove

--[=[
    Takes a table of net types and implements them.

    @within Net
    @param bridgeId string
    @param netTypes {any: [TypeClass]}

    @return {any: [TypeClass]}
]=]

local function now(bridgeId, netTypes)
    if netTypes == Trove then
        netTypes = useTrove(bridgeId)
    end

    for name, netType in netTypes do
        netType:_implement(bridgeId, name)
    end

    return netTypes
end

return now