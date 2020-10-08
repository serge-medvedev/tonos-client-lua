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

local abi = {}

function abi.decode_message(ctx, abi, message)
    local params_json = json.encode({ abi = abi, message = message })
    local response_handle = tc.request_sync(ctx, "abi.decode_message", params_json)

    return check_response(response_handle)
end

function abi.attach_signature(ctx, abi, public_key, message, signature)
    local params_json = json.encode(
        { abi = abi, public_key = public_key, message = message, signature = signature })
    local response_handle = tc.request_sync(ctx, "abi.attach_signature", params_json)

    return check_response(response_handle)
end

function abi.encode_message(ctx, abi, address, deploy_set, call_set, signer, processing_try_index)
    local params_json = json.encode(
        { abi = abi,
          address = address,
          deploy_set = deploy_set,
          call_set = call_set,
          signer = signer,
          processing_try_index = processing_try_index })
    local response_handle = tc.request_sync(ctx, "abi.encode_message", params_json)

    return check_response(response_handle)
end

return abi

