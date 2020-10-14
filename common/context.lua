local tc = require "tonclua"
local check_sync_response = require "check_sync_response"

local context = {}

function context.create(config)
    local response_handle = tc.create_context(config)
    local successful, result = pcall(check_sync_response, response_handle)

    if not successful then
        error(result)
    end

    return result
end

function context.destroy(handle)
    tc.destroy_context(handle)
end

return context

