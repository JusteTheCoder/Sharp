--[=[
    Functions for manipulating arrays.

    @class Array
]=]

local rng = Random.new()

local function filter(t, fn)
    local result = table.create(#t)

    for key, value in ipairs(t) do
        if fn(value, key) then
            result[key] = value
        end
    end

    return result
end

local function map(t, fn)
    local result = table.create(#t)

	for key, value in ipairs(t) do
		result[key] = fn(value, key)
	end

	return result
end

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

local function find(t, fn)
    for key, value in ipairs(t) do
        if fn(value, key) then
            return value, key
        end
    end

    return nil
end

local function every(t, fn)
    for key, value in ipairs(t) do
        if not fn(value, key) then
            return false
        end
    end

    return true
end

local function some(t, fn)
    for key, value in ipairs(t) do
        if fn(value, key) then
            return true
        end
    end

    return false
end

local function swapRemove(t, i)
	local n = #t
	t[i] = t[n]
	t[n] = nil
end

local function swapRemoveFirst(t, v)
    local i = table.find(t, v)
    if i then
        swapRemove(t, i)
    end
    return i
end

local function reverse(t)
    local result = table.create(#t)

    for i = #t, 1, -1 do
        result[i] = t[i]
    end

    return result
end

local function shuffle(t, rngOverride)
    local result = table.clone(t)
    rngOverride = rngOverride or rng
    for i = #result, 2, -1 do
        local j = rngOverride:NextInteger(1, i)
        result[i], result[j] = result[j], result[i]
    end
    return result
end

local function sample(t, n, rngOverride)
    local result = table.create(n)
    rngOverride = rngOverride or rng
    for i = 1, n do
        local j = rngOverride:NextInteger(1, #t)
        result[i] = t[j]
    end
    return result
end

local function flat(t, depth)
	depth = depth or 1
    local result = table.create(#t)

    local function scan(t2, d)
        for _, v in ipairs(t2) do
            if type(v) == "table" and d < depth then
                scan(v, d - 1)
            else
                result[#result + 1] = v
            end
        end
    end
    scan(t, 0)
    return result
end

local function flatMap(t, fn)
    return flat(map(t, fn))
end

local function merge(t1, t2)
    return table.move(t2, 1, #t2, #t1 + 1, t1)
end

local function mergeAll(t1, ...)
    local n = select('#', ...)
    for i = 1, n do
        merge(t1, select(i, ...))
    end
    return t1
end

local function truncate(t, i)
    return table.move(t, 1, i, 1, table.create(i))
end

local function lock(t)
    for _, value in ipairs(t) do
        if type(value) == "table" then
            lock(value)
        end
    end

    table.freeze(t)
    return t
end

local function deepCopy(t)
    local result = table.clone(t)

	for key, value in ipairs(result) do
		if type(value) == "table" then
			result[key] = deepCopy(value)
		end
	end

	return result
end

local function cut(t, i)
    local size = #t
    return table.move(t, 1, i, 1, table.create(i)), table.move(t, i + 1, size, 1, table.create(size - i))
end

return {
    filter = filter,
    map = map,
    reduce = reduce,
    find = find,
    every = every,
    some = some,
    swapRemove = swapRemove,
    swapRemoveFirst = swapRemoveFirst,
    reverse = reverse,
    shuffle = shuffle,
    sample = sample,
    flat = flat,
    flatMap = flatMap,
    merge = merge,
    mergeAll = mergeAll,
    truncate = truncate,
    lock = lock,
    copy = table.clone,
    deepCopy = deepCopy,
    cut = cut
}