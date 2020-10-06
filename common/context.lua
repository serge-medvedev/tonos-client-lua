local tc = require "tonclua"
local json = require "json"

local context = {}

function context.create(config)
    local response_handle = tc.create_context(config)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function context.destroy(handle)
    tc.destroy_context(handle)
end

return context

