local NetPackage = _G.Sharp.Package.Net

--[=[
	A network library designed to be used in conjunction with the Sharp framework.
	@class Net
]=]

return {
	Type = NetPackage.Type,
	Middleware = NetPackage.Middleware,
	Trove = NetPackage.Trove,

	chain = NetPackage.chain,

	now = NetPackage.now,
	use = NetPackage.use,
	with = NetPackage.with,
}
