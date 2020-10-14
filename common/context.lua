local tc = require "tonclua"
local json = require "dkjson"

local context = {}

function context.create(config)
    local response_handle = tc.create_context(config)
    local _, result = tc.read_string(response_handle)
    local decoded = json.decode(result)

    if decoded == nil then
        error("no response")
    elseif decoded.error then
        error(decoded.error)
    end

    return decoded.result
end

function context.destroy(handle)
    tc.destroy_context(handle)
end

return context

