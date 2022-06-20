--[=[
	A collection of functions for manipulating arrays.

	@class Array
]=]

--[=[
	Merges two arrays together.

	@within Array
	@param t1 {T}
	@param t2 {U}

	@return {T, U}
]=]

local function merge(t1, t2)
	return table.move(t2, 1, #t2, #t1 + 1, t1)
end

--[=[
	Create a copy of an array.

	@within Array
	@function copy
	@param t {T}

	@return {T}
]=]

local copy = table.clone

--[=[
	Deep copies an array.

	@within Array
	@param t {T}

	@return {T}
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
	Maps a function over an array.

	@within Array
	@param t {T}
	@param fn (value: T, key: number) -> U

	@return {U}
]=]

local function map(t, fn)
	local result = table.create(#t)

	for key, value in t do
		result[key] = fn(value, key)
	end

	return result
end

--[=[
	Filters an array using a predicate.

	@within Array
	@param t {T}
	@param fn (value: T, key: number) -> boolean

	@return {T}
]=]

local function filter(t, fn)
	local result = table.create(#t)

	for key, value in t do
		if fn(value, key) then
			result[key] = value
		end
	end

	return result
end

--[=[
	Returns the first element in an array that satisfies a predicate.

	@within Array
	@param t {T}
	@param fn (value: T, key: number) -> boolean

	@return T, number
]=]

local function find(t, fn)
	for key, value in t do
		if fn(value, key) then
			return value, key
		end
	end

	return nil
end

--[=[
	Reverse an array.

	@within Array
	@param t {T}

	@return {T}
]=]

local function reverse(t)
	local result = table.create(#t)

	for i = #t, 1, -1 do
		result[i] = t[i]
	end

	return result
end

--[=[
	Performs a reduce operation on an array.

	@within Array
	@param t {T}
	@param fn (accumulator: U, value: T, key: number) -> U
	@param initialAccumulator U

	@return U
]=]

local function reduce(t, fn, initialAccumulator)
	local accumulator = initialAccumulator
	local start = 1

	if accumulator == nil then
		accumulator = t[1]
		start = 2
	end

	for i = start, #t do
		accumulator = fn(accumulator, t[i], i)
	end

	return accumulator
end

--[=[
	Return a flattened version of an array.

	@within Array
	@param t {T}

	@return {T}
]=]

local function flatten(t)
	local result = table.create(#t)

	for _, value in t do
		if type(value) == "table" then
			for _, value2 in value do
				table.insert(result, value2)
			end
		end

		table.insert(result, value)
	end

	return result
end

return table.freeze({
	merge = merge,
	copy = copy,
	deepCopy = deepCopy,
	map = map,
	filter = filter,
	find = find,
	reverse = reverse,
	reduce = reduce,
	flatten = flatten,
})
