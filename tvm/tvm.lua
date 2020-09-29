local tc = require "tonclua"
local json = require "json"

local tvm = {}

function tvm.estimate_fees(ctx)
    local params_json
    local response_handle = tc.json_request(ctx, "tvm.estimate_fees", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

return tvm

