--[=[
	Disrupt Middleware
	This middleware is used to disrupt the flow of requests to a given endpoint.

	@within NetMiddleware
	@function Disrupt
]=]

local function disruptMiddleware(fn)
	local middleware = { cycle = "client", priority = 0 }

	function middleware:process(_, client)
		return fn(client)
	end

	return middleware
end

return disruptMiddleware
