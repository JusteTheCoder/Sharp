--[=[
	@class TableUtil

	A library containing functions for manipulating dictionaries, arrays, and sets.
	Holds [Dictionary], [Array], and [Set] classes.
]=]

return table.freeze({
	dictionary = require(script.Dictionary),
	array = require(script.Array),
	set = require(script.Set),
})
