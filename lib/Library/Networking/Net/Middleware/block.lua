local BLOCK_ERROR = "Blocked event call %s to %s."

local function block(fn)
	return function(netType)
		return function(client, ...)
			local result = fn(client, ...)

			if not result then
				return false, BLOCK_ERROR:format(netType.name, client.Name)
			end

			return true
		end
	end
end

return block
