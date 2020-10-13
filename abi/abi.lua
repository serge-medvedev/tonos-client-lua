local tc = require "tonclua"
local check_sync_response = require "check_sync_response"
local json = require "json"

local abi = {}

function abi.decode_message(ctx, abi, message)
    local params_json = json.encode({
        abi = abi,
        message = message
    })
    local response_handle = tc.request_sync(ctx, "abi.decode_message", params_json)
    local successful, result = pcall(check_sync_response, response_handle)

    if not successful then
        error(result)
    end

    return result
end

function abi.attach_signature(ctx, abi, public_key, message, signature)
    local params_json = json.encode({
        abi = abi,
        public_key = public_key,
        message = message,
        signature = signature
    })
    local response_handle = tc.request_sync(ctx, "abi.attach_signature", params_json)
    local successful, result = pcall(check_sync_response, response_handle)

    if not successful then
        error(result)
    end

    return result
end

function abi.encode_message(ctx, abi, address, deploy_set, call_set, signer, processing_try_index)
    local params_json = json.encode({
        abi = abi,
        address = address,
        deploy_set = deploy_set,
        call_set = call_set,
        signer = signer,
        processing_try_index = processing_try_index
    })
    local response_handle = tc.request_sync(ctx, "abi.encode_message", params_json)
    local successful, result = pcall(check_sync_response, response_handle)

    if not successful then
        error(result)
    end

    return result
end

function abi.encode_account(ctx, state_init, balance, last_trans_lt, last_paid)
    local params_json = json.encode({
        state_init = state_init,
        balance = balance,
        last_trans_lt = last_trans_lt,
        last_paid = last_paid
    })
    local response_handle = tc.request_sync(ctx, "abi.encode_account", params_json)
    local successful, result = pcall(check_sync_response, response_handle)

    if not successful then
        error(result)
    end

    return result
end

return abi

