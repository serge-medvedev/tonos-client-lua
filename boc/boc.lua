local tc = require "tonclua"
local json = require "json"

local function parse_impl(ctx, method, boc)
    local params_json = json.encode({ boc = boc })
    local response_handle = tc.request_sync(ctx, method, params_json)
    local _, result = tc.read_string(response_handle)
    local decoded = json.decode(result)

    if decoded == nil then
        error("no response")
    elseif decoded.error then
        error(decoded.error)
    end

    return decoded.result
end

local boc = {}

function boc.parse_transaction(ctx, transaction)
    return parse_impl(ctx, "boc.parse_transaction", transaction)
end

function boc.parse_block(ctx, block)
    return parse_impl(ctx, "boc.parse_block", block)
end

function boc.parse_account(ctx, account)
    return parse_impl(ctx, "boc.parse_account", account)
end

function boc.parse_message(ctx, message)
    return parse_impl(ctx, "boc.parse_message", message)
end

return boc

