--[=[
	Functions for working with numbers.

	@class Numbers
]=]

--[=[
	Linear interpolation between two numbers.

	@within Numbers
	@param a number
	@param b number
	@param t number

	@return number
]=]

local function lerp(a, b, t)
	return a + (b - a) * t
end

--[=[
	Returns a fraction t, based on a value between a and b.

	@within Numbers
	@param a number
	@param b number
	@param value number

	@return number
]=]

local function inverseLerp(a, b, value)
	return (value - a) / (b - a)
end

--[=[
	Maps a number from one range to another.

	@within Numbers
	@param value number
	@param fromMin number
	@param fromMax number
	@param toMin number
	@param toMax number

	@return number
]=]

local function map(value, fromMin, fromMax, toMin, toMax)
	return toMin + (value - fromMin) * (toMax - toMin) / (fromMax - fromMin)
end

--[=[
	Returns the absolute angle.

	@within Numbers
	@param angle number

	@return number number
]=]

local function absAngle(angle)
	return angle % (2 * math.pi)
end

--[=[
	Returns the shortest angle between two angles in radians.

	@within Numbers
	@param a number
	@param b number

	@return number
]=]

local function shortestAngle(a, b)
	local diff = absAngle(b - a)
	if diff > math.pi then
		return 2 * math.pi - diff
	else
		return diff
	end
end

--[=[
	Lerps an angle.
	Would it make sense to have this function return an absolute angle?
	I don't know. It may mess up some things.

	@within Numbers
	@param a number
	@param b number
	@param t number

	@return number
]=]

local function angleLerp(a, b, t)
	return a + shortestAngle(b, a) * t
end

return table.freeze({
	lerp = lerp,
	inverseLerp = inverseLerp,
	map = map,
	absAngle = absAngle,
	shortestAngle = shortestAngle,
	angleLerp = angleLerp,
})
