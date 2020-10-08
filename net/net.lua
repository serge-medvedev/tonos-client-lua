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

local net = {}

-- collection names: accounts, blocks, transactions, messages, block_signatures

function net.query_collection(ctx, collection, filter, result, order, limit)
    local params_json = json.encode(
        { collection = collection, filter = filter, result = result, order = order, limit = limit })
    local response_handle = tc.request_sync(ctx, "net.query_collection", params_json)

    return check_response(response_handle)
end

function net.unsubscribe(ctx, handle)
    local params_json = json.encode({ handle = handle })

    tc.request_sync(ctx, "net.unsubscribe", params_json)
end

function net.subscribe_collection(ctx, collection, filter, result, on_result)
    local params_json = json.encode({ collection = collection, filter = filter, result = result })

    tc.request(ctx, "net.subscribe_collection", params_json, on_result)
end

function net.wait_for_collection(ctx, collection, filter, result, timeout)
    local params_json = json.encode(
        { collection = collection, filter = filter, result = result, timeout = timeout })
    local response_handle = tc.request_sync(ctx, "net.wait_for_collection", params_json)

    return check_response(response_handle)
end

return net

