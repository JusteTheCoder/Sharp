--[=[
	Deserialize middleware
	This middleware deserializes data before sending it to the target.

	@within NetMiddleware
	@function Deserialize
]=]

local RunService = game:GetService("RunService")
local isClient = RunService:IsClient()

local function deserializeMiddleware(fn)
	local middleware = { cycle = "result", priority = 100 }

	function middleware:process(_, client, args)
		return { fn(table.unpack(isClient and client or args)) }
	end

	return middleware
end

return deserializeMiddleware
