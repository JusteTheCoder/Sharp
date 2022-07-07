local NetPackage = _G.Sharp.Package.Net

--[=[
	Middleware for the Net library.
	@class NetMiddleware
]=]

--[=[
    @interface NetMiddlewareDefinition
    .self ([TypeClass]) -> (client, ...) -> boolean, string?
]=]

return {
	block = NetPackage.block,
	throttle = NetPackage.throttle,
	typeCheck = NetPackage.typeCheck,
}
