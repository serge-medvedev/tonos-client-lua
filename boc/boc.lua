local tc = require "tonclua"
local json = require "json"

local function check_response(response_handle)
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
    local params_json = json.encode({ boc = transaction })
    local response_handle = tc.request_sync(ctx, "boc.parse_transaction", params_json)

    return check_response(response_handle)
end

function boc.parse_block(ctx, block)
    local params_json = json.encode({ boc = block })
    local response_handle = tc.request_sync(ctx, "boc.parse_block", params_json)

    return check_response(response_handle)
end

function boc.parse_account(ctx, account)
    local params_json = json.encode({ boc = account })
    local response_handle = tc.request_sync(ctx, "boc.parse_account", params_json)

    return check_response(response_handle)
end

function boc.parse_message(ctx, message)
    local params_json = json.encode({ boc = message })
    local response_handle = tc.request_sync(ctx, "boc.parse_message", params_json)

    return check_response(response_handle)
end

function boc.get_blockchain_config(ctx, block_boc)
    local params_json = json.encode({ block_boc = block_boc })
    local response_handle = tc.request_sync(ctx, "boc.get_blockchain_config", params_json)

    return check_response(response_handle)
end

return boc

