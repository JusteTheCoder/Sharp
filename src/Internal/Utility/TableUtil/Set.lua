--[=[
	A collection of functions for manipulating sets.
	Sets are a collection of unique keys where each key
	can only appear once and is represented by a boolean value.

	```lua
	local set = { a = true, b = true, c = true }
	```

	@class Set
]=]

--[[
	@type SetArr {any: boolean}
	@within Set
	a dictionary containing only boolean values.
]]

--[=[
	Gets the intersection of sets.

	```lua
	local set1 = { a = true, b = true, c = true }
	local set2 = { b = true, c = true, d = true }
	intersection(set1, set2) -- { b = true, c = true }
	```

	@within Set
	@param ... SetArr

	@return SetArr
]=]

local function intersection(...)
	local sets = { ... }
	local result = {}

	for key in ... do
		local intersects = true

		for i = 2, #sets do
			if not sets[i][key] then
				intersects = false
				break
			end
		end

		if intersects then
			result[key] = true
		end
	end

	return result
end

--[=[
	Gets the union of sets.

	```lua
	local set1 = { a = true, b = true, c = true }
	local set2 = { b = true, c = true, d = true }
	union(set1, set2) -- { a = true, b = true, c = true, d = true }
	```

	@within Set
	@param ... SetArr

	@return SetArr
]=]

local function union(...)
	local sets = { ... }
	local result = {}

	for set in sets do
		for key in set do
			result[key] = true
		end
	end

	return result
end

--[=[
	Gets the difference of sets.

	```lua
	local set1 = { a = true, b = true, c = true }
	local set2 = { b = true, c = true, d = true }
	difference(set1, set2) -- { a = true }
	```

	@within Set
	@param ... SetArr

	@return SetArr
]=]

local function difference(...)
	local sets = { ... }
	local result = {}

	for key in ... do
		local contained = false

		for i = 2, #sets do
			if sets[i][key] then
				contained = true
				break
			end
		end

		if contained == false then
			result[key] = true
		end
	end

	return result
end

return table.freeze({
	intersection = intersection,
	union = union,
	difference = difference,
})
