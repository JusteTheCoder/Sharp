--[=[
	A collection of functions for manipulating dictionaries.

	@class Dictionary
]=]

--[=[
	Merges two dictionaries together.

	@within Dictionary
	@param t1 {[T]: U}]}
	@param t2 {[Y]: Z}]}

	@return {T: U, Y: Z}
]=]

local function merge(t1, t2)
	for key, value in t2 do
		t1[key] = value
	end

	return t1
end

--[=[
	Deep merges two dictionaries together.

	@within Dictionary
	@param t1 {[T]: U}]}
	@param t2 {[Y]: Z}]}

	@return {T: U, Y: Z}
]=]

local function deepMerge(t1, t2)
	for key, value in t2 do
		if type(value) == "table" then
			local targetTable = t1[key]
			if targetTable then
				deepMerge(targetTable, value)
			else
				t1[key] = value
			end
		else
			t1[key] = value
		end
	end

	return t1
end

--[=[
	Create a copy of a dictionary.

	@within Dictionary
	@function copy
	@param t {[T]: U}

	@return {[T]: U}
]=]

local copy = table.clone

--[=[
	Create a deep copy of a dictionary.

	@within Dictionary
	@param t {[T]: U}

	@return {[T]: U}
]=]

local function deepCopy(t)
	local result = table.clone(t)

	for key, value in result do
		if type(value) == "table" then
			result[key] = deepCopy(value)
		end
	end

	return result
end

--[=[
	Returns true if the dictionary is empty.

	@within Dictionary
	@param t {[T]: U}

	@return boolean
]=]

local function isEmpty(t)
	return next(t) == nil
end

--[=[
	Gets the size of a dictionary.

	@within Dictionary
	@param t {[T]: U}

	@return number
]=]

local function size(t)
	local count = 0

	for _ in t do
		count = count + 1
	end

	return count
end

--[=[
	Maps a function over a dictionary.

	@within Dictionary
	@param t {[T]: U}
	@param fn {(T, U) -> V}

	@return {[T]: V}
]=]

local function map(t, fn)
	local result = {}

	for key, value in t do
		result[key] = fn(key, value)
	end

	return result
end

--[=[
	Filters a dictionary using a predicate.

	@within Dictionary
	@param t {[T]: U}
	@param fn {(T, U) -> boolean}

	@return {[T]: U}
]=]

local function filter(t, fn)
	local result = {}

	for key, value in t do
		if fn(key, value) then
			result[key] = value
		end
	end

	return result
end

--[=[
	Performs a reduce operation on a dictionary.

	@within Dictionary
	@param t {[T]: U}
	@param fn {(V, T, U) -> V}
	@param initialAccumulator {V}

	@return {V}
]=]

local function reduce(t, fn, initialAccumulator)
	local accumulator = initialAccumulator
	local start = nil

	if accumulator == nil then
		accumulator = next(t)
		start = accumulator
	end

	for k, v in next, t, start do
		accumulator = fn(accumulator, v, k, t)
	end

	return accumulator
end

--[=[
	Fills in missing keys in a dictionary with values from a template dictionary.

	@within Dictionary
	@param t {[T]: U}
	@param template {[Y]: Z}

	@return {[T]: U}
]=]

local function fill(t, template)
	for key, value in template do
		if t[key] == nil then
			t[key] = value
		end
	end

	return t
end

return table.freeze({
	merge = merge,
	deepMerge = deepMerge,
	copy = copy,
	deepCopy = deepCopy,
	isEmpty = isEmpty,
	size = size,
	map = map,
	filter = filter,
	reduce = reduce,
	fill = fill
})
