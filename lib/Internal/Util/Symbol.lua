--[=[
    A symbol is a unique identifier often used as private keys or objects.

    @class Symbol
]=]

--[=[
    @interface SymbolType
    .__tostring () -> string
]=]

--[=[
    Creates a new symbol.

    @within Symbol
    @param name string?
    @return [Symbol.SymbolType]
]=]

local function new(name)
    local symbol = newproxy(true)
    getmetatable(symbol).__tostring = function()
        return name or "Symbol"
    end
    return symbol
end

return new