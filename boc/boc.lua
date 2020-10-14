local tc_await = require "tc_await"
local json = require "dkjson"

local boc = {}

function boc.parse_transaction(ctx, transaction)
    local params_json = json.encode({ boc = transaction })

    return tc_await(ctx, "boc.parse_transaction", params_json, "parsed")
end

function boc.parse_block(ctx, block)
    local params_json = json.encode({ boc = block })

    return tc_await(ctx, "boc.parse_block", params_json, "parsed")
end

function boc.parse_account(ctx, account)
    local params_json = json.encode({ boc = account })

    return tc_await(ctx, "boc.parse_account", params_json, "parsed")
end

function boc.parse_message(ctx, message)
    local params_json = json.encode({ boc = message })

    return tc_await(ctx, "boc.parse_message", params_json, "parsed")
end

function boc.get_blockchain_config(ctx, block_boc)
    local params_json = json.encode({ block_boc = block_boc })

    return tc_await(ctx, "boc.get_blockchain_config", params_json, "parsed")
end

return boc

