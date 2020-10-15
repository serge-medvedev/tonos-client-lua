local async = require "ton.commons.async"

local processing = {}

function processing.send_message(ctx, message, abi, send_events)
    local params_json = {
        message = message,
        abi = abi,
        send_events = send_events
    }

    return async.iterator_factory(ctx, "processing.send_message", params_json)
end

function processing.wait_for_transaction(ctx, message, abi, shard_block_id, send_events)
    local params_json = {
        abi = abi,
        message = message,
        shard_block_id = shard_block_id,
        send_events = send_events
    }

    return async.iterator_factory(ctx, "processing.wait_for_transaction", params_json)
end

function processing.process_message(ctx, message, abi, send_events)
    local params_json = {
        message = { Encoded = { message = message, abi = abi } },
        send_events = send_events
    }

    return async.iterator_factory(ctx, "processing.process_message", params_json)
end

return processing

