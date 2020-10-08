local tc = require "tonclua"
local json = require "json"

local function check_response(response_handle)
    local _, result = tc.read_string(response_handle)
    local decoded = json.decode(result)

    if decoded.error then
        error(decoded.error.message)
    end

    return decoded.result
end

local client = {}

function client.version(ctx)
    local response_handle = tc.request_sync(ctx, "client.version", "")

    return check_response(response_handle)
end

function client.get_api_reference(ctx)
    local response_handle = tc.request_sync(ctx, "client.get_api_reference", "")

    return check_response(response_handle)
end

return client

