local tc = require "tonclua"
local check_sync_response = require "check_sync_response"
local json = require "json"

local client = {}

function client.version(ctx)
    local response_handle = tc.request_sync(ctx, "client.version", "")
    local successful, result = pcall(check_sync_response, response_handle)

    if not successful then
        error(result)
    end

    return result
end

function client.get_api_reference(ctx)
    local response_handle = tc.request_sync(ctx, "client.get_api_reference", "")
    local successful, result = pcall(check_sync_response, response_handle)

    if not successful then
        error(result)
    end

    return result
end

return client

