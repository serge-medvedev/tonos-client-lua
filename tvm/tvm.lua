local tc = require "tonclua"
local json = require "dkjson"

local tvm = {}

function tvm.estimate_fees(ctx)
    local params_json
    local response_handle = tc.request(ctx, "tvm.estimate_fees", params_json)
    local _, result = tc.read_string(response_handle)
    local decoded = json.decode(result)

    if decoded == nil then
        error("no response")
    elseif decoded.error then
        error(decoded.error)
    end

    return decoded.result
end

return tvm

