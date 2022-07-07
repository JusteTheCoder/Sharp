--[=[
	Functions for working with triangles.

	@class Triangles
]=]

--[=[
	Uses law of cosines to solve for the angle between three sides.

	@within Triangles
	@param a number
	@param b number
	@param c number

	@return number
]=]

local function cosineLawAngle(a, b, c)
	local cosine = (a * a + b * b - c * c) / (2 * a * b)
	return math.acos(cosine)
end

--[=[
	Use law of cosines to solve for the length of the third side.

	@within Triangles
	@param a number
	@param b number
	@param gamma number

	@return number
]=]

local function cosineLawSide(a, b, gamma)
	return math.sqrt(a * a + b * b - 2 * a * b * math.cos(gamma))
end

return table.freeze({
	cosineLawAngle = cosineLawAngle,
	cosineLawSide = cosineLawSide,
})
