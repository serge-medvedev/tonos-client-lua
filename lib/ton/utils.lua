local async = require "ton.commons.async"
local json = require "dkjson"

local utils = {}

function utils.convert_address(ctx, address, output_format)
    local params_json = json.encode({
        address = address,
        output_format = output_format
    })

    return async.wait(ctx, "utils.convert_address", params_json)
end

return utils

