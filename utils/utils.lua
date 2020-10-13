local tc = require "tonclua"
local check_sync_response = require "check_sync_response"
local json = require "json"

local utils = {}

function utils.convert_address(ctx, address, output_format)
    local params_json = json.encode({ address = address, output_format = output_format })
    local response_handle = tc.request_sync(ctx, "utils.convert_address", params_json)
    local successful, result = pcall(check_sync_response, response_handle)

    if not successful then
        error(result)
    end

    return result
end

return utils

