local tc = require "tonclua"
local async_iterator_factory = require "async_iterator_factory"
local check_sync_response = require "check_sync_response"
local json = require "dkjson"

local net = {}

-- collection names: accounts, blocks, transactions, messages, block_signatures

function net.query_collection(ctx, collection, filter, result, order, limit)
    local params_json = json.encode({
        collection = collection,
        filter = filter,
        result = result,
        order = order,
        limit = limit
    })
    local response_handle = tc.request_sync(ctx, "net.query_collection", params_json)
    local successful, result = pcall(check_sync_response, response_handle)

    if not successful then
        error(result)
    end

    return result
end

function net.unsubscribe(ctx, handle)
    local params_json = json.encode({ handle = handle })

    tc.request_sync(ctx, "net.unsubscribe", params_json)
end

--! Subscribes you to the stream of collection-dependent items.
--! The first successful response will contain the subscription handle.
--! Don't forget to unsubscribe to prevent the buffering of unnecessary items.
--! @param collection might be "accounts", "blocks", "transactions", "messages" or "block_signatures"
--! @return iterator factory which can be traversed via generic for loop
function net.subscribe_collection(ctx, collection, filter, result)
    local params_json = json.encode({
        collection = collection,
        filter = filter,
        result = result
    })

    return async_iterator_factory(ctx, "net.subscribe_collection", params_json)
end

function net.wait_for_collection(ctx, collection, filter, result, timeout)
    local params_json = json.encode({
        collection = collection,
        filter = filter,
        result = result,
        timeout = timeout
    })
    local response_handle = tc.request_sync(ctx, "net.wait_for_collection", params_json)
    local successful, result = pcall(check_sync_response, response_handle)

    if not successful then
        error(result)
    end

    return result
end

return net

