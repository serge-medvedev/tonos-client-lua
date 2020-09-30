local tc = require "tonclua"
local json = require "json"

local boc = {}

function parse(ctx, method, boc)
    local params_json = json.encode({ boc = boc })
    local response_handle = tc.json_request(ctx, method, params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function boc.parse_transaction(ctx, boc) 
    return parse(ctx, "boc.parse_transaction", boc)
end

function boc.parse_block(ctx, boc)
    return parse(ctx, "boc.parse_block", boc)
end

function boc.parse_account(ctx, boc)
    return parse(ctx, "boc.parse_account", boc)
end

function boc.parse_message(ctx, boc)
    return parse(ctx, "boc.parse_message", boc)
end

return boc

