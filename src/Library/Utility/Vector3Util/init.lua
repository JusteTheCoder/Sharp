--[=[
	A library containing useful functions for manipulating vectors.

	@class Vector3Util
]=]

local EPSILON = 1e-5 -- Used to compare floating point numbers

local Vector3Util = {}

--[=[
	Returns the angle between two vectors.

	@param vector1 Vector3
	@param vector2 Vector3

	@return number
]=]

function Vector3Util.angleBetween(vector1, vector2)
	return math.atan2(vector1:Cross(vector2).Magnitude, vector1:Dot(vector2))
end

--[=[
	Clamps the vector inside a cone.

	@param vector Vector3
	@param normal Vector3
	@param angle number

	@return Vector3
]=]

function Vector3Util.clampInCone(vector, normal, angle)
	local perpendicular = normal:Cross(vector)
	local angleBetween = math.atan2(perpendicular.Magnitude, normal:Dot(vector))

	if angleBetween <= angle then
		return vector
	end

	return CFrame.fromAxisAngle(perpendicular, angle):VectorToWorldSpace(normal)
end

--[=[
	Clamps the vector outside a cone.

	@param vector Vector3
	@param normal Vector3
	@param angle number

	@return Vector3
]=]

function Vector3Util.clampOutsideCone(vector, normal, angle)
	local perpendicular = normal:Cross(vector)
	local angleBetween = math.atan2(perpendicular.Magnitude, normal:Dot(vector))

	if angleBetween >= angle then
		return vector
	end

	return CFrame.fromAxisAngle(perpendicular, angle):VectorToWorldSpace(normal)
end

--[=[
	Return true if the vector is inside the cone.

	@param vector Vector3
	@param normal Vector3
	@param angle number

	@return boolean
]=]

function Vector3Util.isInCone(vector, normal, angle)
	local perpendicular = normal:Cross(vector)
	local angleBetween = math.atan2(perpendicular.Magnitude, normal:Dot(vector))

	return angleBetween <= angle
end

--[=[
	Returns the distance between two vectors.

	@param vector1 Vector3
	@param vector2 Vector3

	@return number
]=]

function Vector3Util.distance(vector1, vector2)
	return (vector1 - vector2).Magnitude
end

--[=[
	Reflects a vector off a surface.

	@param vector Vector3
	@param normal Vector3

	@return Vector3
]=]

function Vector3Util.reflect(vector, normal)
	return vector - 2 * normal:Dot(vector) * normal
end

--[=[
	Returns the closest point on a line segment.

	@param point Vector3
	@param linePoint Vector3
	@param lineDirection Vector3

	@return Vector3
]=]

function Vector3Util.getClosestPointFromLine(point, linePoint, lineDirection)
	local projection = (point - linePoint):Dot(lineDirection) / lineDirection.Magnitude ^ 2
	return linePoint + projection * lineDirection
end

--[=[
	Returns the distance from a point to a line.

	@param point Vector3
	@param linePoint Vector3
	@param lineDirection Vector3

	@return number
]=]

function Vector3Util.getDistanceFromLine(point, linePoint, lineDirection)
	return (point - linePoint):Cross(lineDirection).Magnitude / lineDirection.Magnitude
end

--[=[
	Constructs a vector3 from a vector3 xy.

	@param vector Vector3 | Vector2
	@param z number

	@return Vector3
]=]

function Vector3Util.fromVector2XY(vector, z)
	return Vector3.new(vector.X, vector.Y, z or 0)
end

--[=[
	Constructs a vector3 from a vector3 xz.

	@param vector Vector3 | Vector2
	@param y Vector3

	@return Vector3
]=]

function Vector3Util.fromVector2XZ(vector, y)
	return Vector3.new(vector.X, y or 0, vector.Y)
end

--[=[
	Gets the line plane intersection.

	@param linePoint Vector3
	@param lineDirection Vector3
	@param planePoint Vector3
	@param planeNormal Vector3

	@return Vector3
]=]

function Vector3Util.getLinePlaneIntersection(linePoint, lineDirection, planePoint, planeNormal)
	local t = (planePoint - linePoint):Dot(planeNormal) / lineDirection:Dot(planeNormal)
	return linePoint + lineDirection * t
end

--[=[
	Returns true if the vectors are collinear.

	@param v1 Vector3
	@param v2 Vector3
	@param v3 Vector3

	@return boolean
]=]

function Vector3Util.areCollinear(v1, v2, v3)
	return (v3 - v1):Cross(v3 - v2).Magnitude <= EPSILON
end

--[=[
	Returns true if the vectors are coindicent.

	@param v1 Vector3
	@param v2 Vector3

	@return boolean
]=]

function Vector3Util.areCoincident(v1, v2)
	return (v1 - v2).Magnitude <= EPSILON
end

--[=[
	Returns the normal of a triangle.

	@param v1 Vector3
	@param v2 Vector3
	@param v3 Vector3

	@return Vector3
]=]

function Vector3Util.normal(v1, v2, v3)
	return (v2 - v1):Cross(v3 - v1).Unit
end

--[=[
	Returns the distance from a point to a plane.

	@param point Vector3
	@param planePoint Vector3
	@param planeNormal Vector3

	@return number
]=]

function Vector3Util.getDistanceFromPlane(point, planePoint, planeNormal)
	return (point - planePoint):Dot(planeNormal)
end

--[=[
	Clamps the magnitude of a vector

	@param vector Vector3
	@param maxMagnitude number

	@return Vector3
]=]

function Vector3Util.clampMagnitude(vector, maxMagnitude)
	return vector.Magnitude > maxMagnitude and vector.Unit * maxMagnitude or vector
end

--[=[
	Returns a vector where the y component is 0.

	@param vector Vector3

	@return Vector3
]=]

function Vector3Util.flat(vector)
	return Vector3.new(vector.X, 0, vector.Z)
end

--[=[
	Returns a vector from angle.

	@param angle number
	@param magnitude number?

	@return Vector3
]=]

function Vector3Util.fromAngle(angle, magnitude)
	magnitude = magnitude or 1
	return Vector3.new(math.sin(angle), 0, math.cos(angle)) * magnitude
end

table.freeze(Vector3Util)
return Vector3Util
