--[=[
	An utily library for working with Bezier curves.

	A bezier curve is defined by the following formula:

	B(t) = (1 - t)^n * P0 +
		   n * (1 - t)^(n - 1) * t * P1 +
		   n * (1 - t)^(n - 2) * t^2 * P2 +
		   ... +
		   n * (1 - t)^2 * t^(n - 1) * Pn

	where n is the number of points, P0, P1, P2, ..., Pn are
	the points, and t is the parameter between 0 and 1.

	@class Bezier
]=]

--[=[
	Computes the point on the quadratic curve for a given parameter t.

	@within Bezier
	@function quadratic
	@param startPoint number | T
	@param controlPoint number | T
	@param endPoint number | T
	@param t number | T

	@return number | T
]=]

local function quadraticBezierCurve(startPoint, controlPoint, endPoint, t)
	return (1 - t) ^ 2 * startPoint + 2 * (1 - t) * t * controlPoint + t ^ 2 * endPoint
end

--[=[
	Computes the point on the cubic curve for a given parameter t.

	@within Bezier
	@function cubic
	@param startPoint number | T
	@param controlPoint1 number | T
	@param controlPoint2 number | T
	@param endPoint number | T
	@param t number | T

	@return number | T
]=]

local function cubicBezierCurve(startPoint, controlPoint1, controlPoint2, endPoint, t)
	return (1 - t) ^ 3 * startPoint
		+ 3 * (1 - t) ^ 2 * t * controlPoint1
		+ 3 * (1 - t) * t ^ 2 * controlPoint2
		+ t ^ 3 * endPoint
end

--[=[
	Computes the point on the n-th degree curve for a given parameter t.

	:::caution

	Due to performance reasons, it is not recommended to use this function.

	:::

	@within Bezier
	@function nth
	@param points table | T
	@param t number | T

	@return number | T
]=]

local function nDegreeBezierCurve(controlPoints, t)
	local startPoint = controlPoints[1]
	local endPoint = controlPoints[#controlPoints]

	local n = #controlPoints
	local result = (1 - t) ^ n * startPoint

	for i = 1, n do
		result += (1 - t) ^ (n - i) * t ^ i * controlPoints[i]
	end

	return result + n * (1 - t) ^ 2 * t ^ (n - 1) * endPoint
end

return table.freeze({
	quadratic = quadraticBezierCurve,
	cubic = cubicBezierCurve,
	nth = nDegreeBezierCurve,
})
