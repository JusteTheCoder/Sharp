--[=[
    Functions for metatable manipulation.

    @class Meta
]=]

local weakKeysMeta = { __mode = "k" }
local weakValuesMeta = { __mode = "v" }
local weakMeta = { __mode = "kv" }

local function weakKeys(t)
	return setmetatable(t or {}, weakKeysMeta)
end

local function weakValues(t)
	return setmetatable(t or {}, weakValuesMeta)
end

local function weak(t)
	return setmetatable(t or {}, weakMeta)
end

return {
	weakKeys = weakKeys,
	weakValues = weakValues,
	weak = weak,
}
