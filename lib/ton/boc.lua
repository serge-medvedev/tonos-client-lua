local async = require "ton.commons.async"

local boc = {}

function boc.parse_transaction(ctx, transaction)
    local params_json = { boc = transaction }

    return async.iterator_factory(ctx, "boc.parse_transaction", params_json).pick("parsed")
end

function boc.parse_block(ctx, block)
    local params_json = { boc = block }

    return async.iterator_factory(ctx, "boc.parse_block", params_json).pick("parsed")
end

function boc.parse_account(ctx, account)
    local params_json = { boc = account }

    return async.iterator_factory(ctx, "boc.parse_account", params_json).pick("parsed")
end

function boc.parse_message(ctx, message)
    local params_json = { boc = message }

    return async.iterator_factory(ctx, "boc.parse_message", params_json).pick("parsed")
end

function boc.get_blockchain_config(ctx, block_boc)
    local params_json = { block_boc = block_boc }

    return async.iterator_factory(ctx, "boc.get_blockchain_config", params_json).pick("parsed")
end

return boc

