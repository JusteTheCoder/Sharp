local Sharp = _G.Sharp

local Symbol = Sharp.Library.Symbol
local NetPackage = Sharp.Package.Net
local Trove = NetPackage.Trove
local useTrove = NetPackage.useTrove

local bridgeIndex = Symbol("bridgeIndex")

--[=[
    @within Net
    @param netTypes {any: [TypeClass]}

    @return {any: [TypeClass]}
]=]

local function netAdd(self, netTypes)
    local bridgeId = self[bridgeIndex]

    if netTypes == Trove then
        netTypes = useTrove(bridgeId)
    end

    for name, netType in netTypes do
        netType:_implement(bridgeId, name)
        self[name] = netType
    end

    return self
end

--[=[
    Takes a targetTable and adds a netAdd method to add net types to it.

    @within Net
    @param bridgeId string
    @param targetTable {any: any}?

    @return {any: any}?
]=]

local function use(bridgeId, targetTable)
    targetTable = targetTable or {}

    targetTable.netAdd = netAdd
    targetTable[bridgeIndex] = bridgeId

    return targetTable
end

return use