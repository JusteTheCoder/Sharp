--[=[
	@class TableUtil

	A library containing functions for manipulating dictionaries, arrays, and sets.
	Holds [Dictionary], [Array], and [Set] classes.
]=]

local WEAK_KEYS_METATABLE = {
	__mode = "k",
}

--[=[
	Use weak keys for a table.

	@within TableUtil
	@param table {any: any}

	@return table {any: any}
]=]

local function weak(t)
	return setmetatable(t, WEAK_KEYS_METATABLE)
end

return table.freeze({
	dictionary = require(script.Dictionary),
	array = require(script.Array),
	set = require(script.Set),

	weak = weak,
})
