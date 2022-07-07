local BLOCK_ERROR = "Client %s called %s with invalid arguments:\n%s"
local UNKNOWN_ERROR = "Unknown error."

local function typeCheck(...)
	local typeCheckFunctions = { ... }
	return function(netType)
		return function(client, ...)
			for i = 1, select("#", ...) do
				local arg = select(i, ...)
				local typeCheckFunction = typeCheckFunctions[i]

				if not typeCheckFunction then
					return false, BLOCK_ERROR:format(client.Name, netType._name, UNKNOWN_ERROR)
				end

				local status, err = typeCheckFunction(arg)
				if not status then
					err = err or UNKNOWN_ERROR
					return false, BLOCK_ERROR:format(client.Name, netType._name, err)
				end
			end

			return true
		end
	end
end

return typeCheck
