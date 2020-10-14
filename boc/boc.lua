local tc = require "tonclua"
local check_sync_response = require "check_sync_response"
local json = require "dkjson"

local boc = {}

function boc.parse_transaction(ctx, transaction)
    local params_json = json.encode({ boc = transaction })
    local response_handle = tc.request_sync(ctx, "boc.parse_transaction", params_json)
    local successful, result = pcall(check_sync_response, response_handle)

    if not successful then
        error(result)
    end

    return result
end

function boc.parse_block(ctx, block)
    local params_json = json.encode({ boc = block })
    local response_handle = tc.request_sync(ctx, "boc.parse_block", params_json)
    local successful, result = pcall(check_sync_response, response_handle)

    if not successful then
        error(result)
    end

    return result
end

function boc.parse_account(ctx, account)
    local params_json = json.encode({ boc = account })
    local response_handle = tc.request_sync(ctx, "boc.parse_account", params_json)
    local successful, result = pcall(check_sync_response, response_handle)

    if not successful then
        error(result)
    end

    return result
end

function boc.parse_message(ctx, message)
    local params_json = json.encode({ boc = message })
    local response_handle = tc.request_sync(ctx, "boc.parse_message", params_json)
    local successful, result = pcall(check_sync_response, response_handle)

    if not successful then
        error(result)
    end

    return result
end

function boc.get_blockchain_config(ctx, block_boc)
    local params_json = json.encode({ block_boc = block_boc })
    local response_handle = tc.request_sync(ctx, "boc.get_blockchain_config", params_json)
    local successful, result = pcall(check_sync_response, response_handle)

    if not successful then
        error(result)
    end

    return result
end

return boc

