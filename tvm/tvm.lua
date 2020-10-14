local tc = require "tonclua"
local check_sync_response = require "check_sync_response"

local tvm = {}

function tvm.estimate_fees(ctx)
    local params_json
    local response_handle = tc.request(ctx, "tvm.estimate_fees", params_json)
    local successful, result = pcall(check_sync_response, response_handle)

    if not successful then
        error(result)
    end

    return result
end

return tvm

