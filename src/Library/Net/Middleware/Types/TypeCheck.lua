--[=[
	TypeCheck middleware
	This middleware is used to check if the type of the request is the same as the type of the response.

	@within NetMiddleware
	@function TypeCheck
]=]

local ERROR_MESSAGE = "Type check failed for argument %d of event '%s'."

local function typeCheckMiddleware(...)
	local middleware = { cycle = "result", priority = 1 }
	local middlewareArgs = { ... }

	function middleware:process(netType, client, args)
		for index, arg in args do
			local typeCheckFunction = middlewareArgs[index]

			if typeCheckFunction == nil then
				continue
			end

			local isValidType = typeCheckFunction(arg)

			if isValidType == false then
				return false, string.format(ERROR_MESSAGE, client.Name, netType._name)
			end
		end

		return true
	end

	return middleware
end

return typeCheckMiddleware
