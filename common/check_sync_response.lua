local tc = require "tonclua"
local json = require "dkjson"

return function (response_handle)
    local _, result = tc.read_string(response_handle)
    local decoded = json.decode(result)

    if decoded == nil then
        error("empty response")
    elseif decoded.error then
        error(decoded.error)
    end

    return decoded.result
end

