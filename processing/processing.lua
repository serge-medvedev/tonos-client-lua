local tc = require "tonclua"
local json = require "json"

local processing = {}

function processing.send_message(ctx, message, abi, send_events, on_response)
    local params_json = json.encode(
        { message = message, abi = abi, send_events = send_events })

    tc.request(ctx, "processing.send_message", params_json, on_response)
end

function processing.wait_for_transaction(ctx, abi, message, shard_block_id, send_events, on_response)
    local params_json = json.encode(
        { abi = abi, message = message, shard_block_id = shard_block_id, send_events = send_events })

    tc.request(ctx, "processing.wait_for_transaction", params_json, on_response)
end

function processing.process_message(ctx, message, send_events, on_response)
    local params_json = json.encode(
        { message = { Encoded = message }, send_events = send_events })

    tc.request(ctx, "processing.process_message", params_json, on_response)
end

return processing

