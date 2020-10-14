local tc_await = require "tc_await"
local json = require "dkjson"

local abi = {}

function abi.decode_message(ctx, abi, message)
    local params_json = json.encode({
        abi = abi,
        message = message
    })

    return tc_await(ctx, "abi.decode_message", params_json)
end

function abi.attach_signature(ctx, abi, public_key, message, signature)
    local params_json = json.encode({
        abi = abi,
        public_key = public_key,
        message = message,
        signature = signature
    })

    return tc_await(ctx, "abi.attach_signature", params_json)
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

    return tc_await(ctx, "abi.encode_message", params_json)
end

function abi.encode_account(ctx, state_init, balance, last_trans_lt, last_paid)
    local params_json = json.encode({
        state_init = state_init,
        balance = balance,
        last_trans_lt = last_trans_lt,
        last_paid = last_paid
    })

    return tc_await(ctx, "abi.encode_account", params_json)
end

return abi

