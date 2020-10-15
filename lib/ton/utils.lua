local async = require "ton.commons.async"

local utils = {}

function utils.convert_address(ctx, address, output_format)
    local params_json = {
        address = address,
        output_format = output_format
    }

    return async.iterator_factory(ctx, "utils.convert_address", params_json)
end

return utils

