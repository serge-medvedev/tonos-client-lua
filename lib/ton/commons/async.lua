local tc = require "tonclua"
local json = require "dkjson"

local async = {}

function async.iterator_factory(ctx, method, params_json)
    return coroutine.wrap(function()
        local request_id, id = tc.request(ctx, method, params_json)

        while request_id ~= id do
            id = tc.fetch_response_data(request_id) -- yields on the C-side, returns request_id when finished
        end
    end)
end

function async.wait(ctx, method, params_json, result_field)
    params_json = params_json or ""

    for request_id, params_json, response_type, finished
        in async.iterator_factory(ctx, method, params_json) do

        if finished then
            local decoded = json.decode(params_json)

            if response_type ~= 0 then
                error(decoded, 2) -- blame the caller
            end

            if result_field then
                return decoded[result_field]
            else
                return decoded
            end
        end
    end
end

return async

