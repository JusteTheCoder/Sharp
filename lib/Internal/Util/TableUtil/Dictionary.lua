--[=[
    Functions for manipulating dictionarys.

    @class Dictionary
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

local function map(t, fn)
    local result = {}

	for key, value in t do
		result[key] = fn(key, value)
	end

	return result
end

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

local function deepCopy(t)
    local result = table.clone(t)

	for key, value in result do
		if type(value) == "table" then
			result[key] = deepCopy(value)
		end
	end

	return result
end

local function sync(t1, t2)
    local target = table.clone(t1)

    for k, v in target do
        local v2 = t2[k]

        if v2 == nil then
            target[k] = nil
        elseif type(v) == "table" and type(v2) == "table" then
            target[k] = sync(v, v2)
        end
    end

    for k, v in t2 do
        local v2 = target[k]

        if v2 == nil then
            if type(v) == "table" then
                target[k] = table.clone(v)
            else
                target[k] = v
            end
        end
    end

    return target
end

local function reconcile(t1, t2)
    local tbl = table.clone(t1)

	for k, v in t2 do
		local sv = t1[k]
		if sv == nil then
			if type(v) == "table" then
				tbl[k] = deepCopy(v)
			else
				tbl[k] = v
			end
		elseif type(sv) == "table" then
			if type(v) == "table" then
				tbl[k] = reconcile(sv, v)
			else
				tbl[k] = deepCopy(sv)
			end
		end
	end

	return tbl
end

local function keys(t)
    local result = {}

    for key in t do
        table.insert(result, key)
    end

    return result
end

local function values(t)
    local result = {}

    for _, value in t do
        table.insert(result, value)
    end

    return result
end

local function merge(t1, t2)
	for key, value in t2 do
		t1[key] = value
	end

	return t1
end

local function mergeAll(t1, ...)
    local n = select('#', ...)
    for i = 1, n do
        merge(t1, select(i, ...))
    end
    return t1
end

local function isEmpty(t)
	return next(t) == nil
end

local function size(t)
	local count = 0

	for _ in t do
		count = count + 1
	end

	return count
end

local function lock(t)
    for _, value in t do
        if type(value) == "table" then
            lock(value)
        end
    end

    table.freeze(t)
    return t
end

local function every(t, fn)
    for key, value in t do
        if not fn(value, key) then
            return false
        end
    end

    return true
end

local function some(t, fn)
    for key, value in t do
        if fn(value, key) then
            return true
        end
    end

    return false
end

local function find(t, fn)
    for key, value in t do
        if fn(value, key) then
            return value, key
        end
    end

    return nil
end

local function fill(t1, t2)
	for key, value in t2 do
		if t1[key] == nil then
			t1[key] = value
		end
	end

	return t1
end

return {
    filter = filter,
    map = map,
    reduce = reduce,
    deepCopy = deepCopy,
    sync = sync,
    reconcile = reconcile,
    keys = keys,
    values = values,
    merge = merge,
    mergeAll = mergeAll,
    isEmpty = isEmpty,
    size = size,
    lock = lock,
    every = every,
    some = some,
    find = find,
    fill = fill,
}