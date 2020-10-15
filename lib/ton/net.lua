local async = require "ton.commons.async"

local net = {}

--! @param collection might be "accounts", "blocks", "transactions", "messages" or "block_signatures"
function net.query_collection(ctx, collection, filter, result, order, limit)
    local params_json = {
        collection = collection,
        filter = filter,
        result = result,
        order = order,
        limit = limit
    }

    return async.iterator_factory(ctx, "net.query_collection", params_json).pick("result")
end

function net.unsubscribe(ctx, handle)
    local params_json = { handle = handle }

    return async.iterator_factory(ctx, "net.unsubscribe", params_json)
end

--! Subscribes you to the stream of collection-dependent events.
--! The first successful response contains the subscription handle.
--! Don't forget to unsubscribe to prevent the buffering of unnecessary events.
--! @param collection might be "accounts", "blocks", "transactions", "messages" or "block_signatures"
--! @return iterator factory which can be traversed via generic for loop
function net.subscribe_collection(ctx, collection, filter, result)
    local params_json = {
        collection = collection,
        filter = filter,
        result = result
    }

    return async.iterator_factory(ctx, "net.subscribe_collection", params_json)
end

--! @param collection might be "accounts", "blocks", "transactions", "messages" or "block_signatures"
function net.wait_for_collection(ctx, collection, filter, result, timeout)
    local params_json = {
        collection = collection,
        filter = filter,
        result = result,
        timeout = timeout
    }

    return async.iterator_factory(ctx, "net.wait_for_collection", params_json).pick("result")
end

return net

