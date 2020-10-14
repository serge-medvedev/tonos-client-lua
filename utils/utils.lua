local tc_await = require "tc_await"
local json = require "dkjson"

local utils = {}

function utils.convert_address(ctx, address, output_format)
    local params_json = json.encode({
        address = address,
        output_format = output_format
    })

    return tc_await(ctx, "utils.convert_address", params_json)
end

return utils

