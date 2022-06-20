--[=[
	Throttle Middleware
	This middleware is used to throttle the number of requests that can be made to a given endpoint.

	@within NetMiddleware
	@function Throttle
]=]

local WEAK_KEYS = { __mode = "k" }
local ERROR_MESSAGE = "Throttle limit exceeded by client '%s' in event '%s'."

local throttles = setmetatable({}, WEAK_KEYS)

local function throttleMiddleware(maxRequestsPerTimePeriod, timePeriod)
	local middleware = { cycle = "result", priority = 0 }
	timePeriod = timePeriod or 60
	function middleware:process(netType, client)
		local typeThrottle = throttles[netType]
		if typeThrottle == nil then
			typeThrottle = setmetatable({}, WEAK_KEYS)
			throttles[netType] = typeThrottle
		end

		local currentTime = os.clock()
		local clientThrottle = typeThrottle[client]
		if clientThrottle == nil then
			clientThrottle = { _timePeriodStart = currentTime, _requests = 0 }
			typeThrottle[client] = clientThrottle
		end

		if currentTime - clientThrottle._timePeriodStart >= timePeriod then
			clientThrottle._timePeriodStart = currentTime
			clientThrottle._requests = 0
		end

		clientThrottle._requests += 1

		if clientThrottle._requests >= maxRequestsPerTimePeriod then
			return false, string.format(ERROR_MESSAGE, client.Name, netType._name)
		end

		return true
	end

	return middleware
end

return throttleMiddleware
