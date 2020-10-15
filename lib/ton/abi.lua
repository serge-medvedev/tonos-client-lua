local async = require "ton.commons.async"

local abi = {}

function abi.decode_message(ctx, abi, message)
    local params_json = {
        abi = abi,
        message = message
    }

    return async.iterator_factory(ctx, "abi.decode_message", params_json)
end

function abi.attach_signature(ctx, abi, public_key, message, signature)
    local params_json = {
        abi = abi,
        public_key = public_key,
        message = message,
        signature = signature
    }

    return async.iterator_factory(ctx, "abi.attach_signature", params_json)
end

function abi.encode_message(ctx, abi, address, deploy_set, call_set, signer, processing_try_index)
    local params_json = {
        abi = abi,
        address = address,
        deploy_set = deploy_set,
        call_set = call_set,
        signer = signer,
        processing_try_index = processing_try_index
    }

    return async.iterator_factory(ctx, "abi.encode_message", params_json)
end

function abi.encode_account(ctx, state_init, balance, last_trans_lt, last_paid)
    local params_json = {
        state_init = state_init,
        balance = balance,
        last_trans_lt = last_trans_lt,
        last_paid = last_paid
    }

    return async.iterator_factory(ctx, "abi.encode_account", params_json)
end

return abi

