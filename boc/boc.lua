local tc = require "tonclua"
local json = require "json"

local boc = {}

function boc.parse_message(ctx, boc)
    local params_json = json.encode({ boc = boc })
    local response_handle = tc.json_request(ctx, "boc.parse_message", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

return boc

