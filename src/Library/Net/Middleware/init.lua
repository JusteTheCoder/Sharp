local Sharp = _G.Sharp

--[=[
	Middleware for the Net library.

	:::caution

	The middleware API is subject to change in future versions.
	The current implementation suffers from performance issues.

	:::

	@class NetMiddleware
]=]

--[=[
	@within NetMiddleware
	@type Middleware {cycle: string, fn: (...: any) -> (...: any) -> any}
]=]

--[=[
	@within NetMiddleware
	@prop result string
	@readonly

	Define a middleware which is called when receiving an event.
]=]

--[=[
	@within NetMiddleware
	@prop argument string
	@readonly

	Define a middleware which is called when sending an event.
]=]

--[=[
	@within NetMiddleware
	@prop client string
	@readonly

	Define a middleware which is called when sending an event to a client.
]=]

--[=[
	Returns true if is a middleware.

	@within NetMiddleware
	@param middleware Middleware
]=]

local function is(middleware)
	return typeof(middleware) == "table" and middleware.cycle ~= nil
end

return table.freeze({
	is = is,

	result = "result",
	argument = "argument",
	client = "client",

	priority = {
		urgent = 0,
		high = 1,
		normal = 2,
		low = 3,
		last = 100,
	},

	deserialize = Sharp.package.Net.Deserialize,
	serialize = Sharp.package.Net.Serialize,
	typeCheck = Sharp.package.Net.TypeCheck,
	throttle = Sharp.package.Net.Throttle,
	disrupt = Sharp.package.Net.Disrupt,
})