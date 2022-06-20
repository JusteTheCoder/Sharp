--[=[
	Serialize middleware
	This middleware serializes the data before sending it to the target.

	@within NetMiddleware
	@function Serialize
]=]

local function serializeMiddleware(fn)
	local middleware = { cycle = "argument", priority = 100 }

	function middleware:process(_, args)
		return { fn(table.unpack(args)) }
	end

	return middleware
end

return serializeMiddleware
