local tc = require "tonclua"
local json = require "json"

local function check_response(response_handle)
    local _, result = tc.read_string(response_handle)
    local decoded = json.decode(result)

    if decoded == nil then
        error("no response")
    elseif decoded.error then
        error(decoded.error)
    end

    return decoded.result
end

local utils = {}

function utils.convert_address(ctx, address, output_format)
    local params_json = json.encode({ address = address, output_format = output_format })
    local response_handle = tc.request_sync(ctx, "utils.convert_address", params_json)

    return check_response(response_handle)
end

return utils

