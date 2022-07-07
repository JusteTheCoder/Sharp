local BLOCK_ERROR = "Blocked event call %s to %."

local function block(fn)
    return function(netType)
        return function(client, ...)
            local result = fn(client, ...)

            if not result then
                return false, BLOCK_ERROR:format(netType._name, client.Name)
            end

            return true
        end
    end
end

return block