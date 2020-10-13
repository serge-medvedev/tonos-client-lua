local tc = require "tonclua"
local async_iterator_factory = require "async_iterator_factory"
local json = require "json"

local processing = {}

function processing.send_message(ctx, message, abi, send_events)
    local params_json = json.encode({
        message = message,
        abi = abi,
        send_events = send_events
    })

    return async_iterator_factory(ctx, "processing.send_message", params_json)
end

function processing.wait_for_transaction(ctx, abi, message, shard_block_id, send_events)
    local params_json = json.encode({
        abi = abi,
        message = message,
        shard_block_id = shard_block_id,
        send_events = send_events
    })

    return async_iterator_factory(ctx, "processing.wait_for_transaction", params_json)
end

function processing.process_message(ctx, message, send_events)
    local params_json = json.encode({
        message = { Encoded = message },
        send_events = send_events
    })

    return async_iterator_factory(ctx, "processing.process_message", params_json)
end

return processing

