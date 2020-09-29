local tc = require "tonclua"
local json = require "json"

local client = {}

function client.version(ctx)
    local response_handle = tc.json_request(ctx, "client.version", "")
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function client.get_api_reference(ctx)
    local response_handle = tc.json_request(ctx, "client.get_api_reference", "")
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

return client
