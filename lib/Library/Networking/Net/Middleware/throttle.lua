local TableUtil = _G.Sharp.Library.TableUtil

local DEFAULT_MAX_REQUESTS_PER_TIME_PERIOD = 10
local DEFAULT_TIMEPERIOD = 60
local THROTTLE_ERROR = "Client %s exhausted the rate limit for %s."

local function throttle(maxRequestsPerTimePeriod, timePeriod)
    maxRequestsPerTimePeriod = maxRequestsPerTimePeriod or DEFAULT_MAX_REQUESTS_PER_TIME_PERIOD
    timePeriod = timePeriod or DEFAULT_TIMEPERIOD

	return function(netType)
        local clientCallTimes = TableUtil.Meta.weakKeys()

		return function(client, ...)
			local clientCallTime = clientCallTimes[client]

			if clientCallTime == nil then
				clientCallTime = {
					_timePeriodStart = os.clock(),
					_requests = 0,
				}

				clientCallTimes[client] = clientCallTime
			end

			local now = os.clock()
            if now - clientCallTime._timePeriodStart >= timePeriod then
                clientCallTime._timePeriodStart = now
                clientCallTime._requests = 0
            end

            clientCallTime._requests += 1
            if clientCallTime._requests > maxRequestsPerTimePeriod then
                return false, THROTTLE_ERROR:format(client.Name, netType._name)
            end

            return true
		end
	end
end

return throttle
