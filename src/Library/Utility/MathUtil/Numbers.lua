--[=[
	Functions for working with numbers.

	@class Numbers
]=]

--[=[
	Linear interpolation between two numbers.

	@within Numbers
	@param a number | T
	@param b number | T
	@param t number | T

	@return number | T
]=]

local function lerp(a, b, t)
	return a + (b - a) * t
end

--[=[
	Returns a fraction t, based on a value between a and b.

	@within Numbers
	@param a number | T
	@param b number | T
	@param value number | T

	@return number | T
]=]

local function inverseLerp(a, b, value)
	return (value - a) / (b - a)
end

--[=[
	Maps a number from one range to another.

	@within Numbers
	@param value number | T
	@param fromMin number | T
	@param fromMax number | T
	@param toMin number | T
	@param toMax number | T

	@return number | T
]=]

local function map(value, fromMin, fromMax, toMin, toMax)
	return toMin + (value - fromMin) * (toMax - toMin) / (fromMax - fromMin)
end

return table.freeze({
	lerp = lerp,
	inverseLerp = inverseLerp,
	map = map,
})
