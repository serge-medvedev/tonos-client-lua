local tc = require "tonclua"
local json = require "json"

local abi = {}

function abi.decode_message(ctx, abi, message)
    local params_json = json.encode({ abi = abi, message = message })
    local response_handle = tc.json_request(ctx, "abi.decode_message", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function abi.attach_signature(ctx, abi, public_key, message, signature)
    local params_json = json.encode(
        { abi = abi, public_key = public_key, message = message, signature = signature })
    local response_handle = tc.json_request(ctx, "abi.attach_signature", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function abi.encode_message(ctx, abi, address, deploy_set, call_set, signer)
    local params_json = json.encode(
        { abi = abi, address = address, deploy_set = deploy_set, call_set = call_set, signer = signer })
    local response_handle = tc.json_request(ctx, "abi.encode_message", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

return abi

