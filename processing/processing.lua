local tc = require "tonclua"
local json = require "json"

local processing = {}

function processing.send_message(ctx, message, events_handler, abi)
    local params_json = json.encode(
        { message = message, events_handler = events_handler, abi = abi })
    local response_handle = tc.json_request(ctx, "processing.send_message", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function processing.process_message(ctx, message, events_handler)
end

function processing.wait_for_transaction(ctx, abi, message, shard_block_id, events_handler)
end

return processing

