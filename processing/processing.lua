local tc = require "tonclua"
local json = require "json"

local processing = {}

function processing.send_message(ctx, message, message_expiration_time, callback)
    local params_json = json.encode(
        { message = message, message_expiration_time = message_expiration_time, callback = callback })
    local response_handle = tc.json_request(ctx, "processing.send_message", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

return processing

