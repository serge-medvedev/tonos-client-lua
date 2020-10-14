local async_iterator_factory = require "async_iterator_factory"
local json = require "dkjson"

return function(ctx, method, params_json, result_field)
    params_json = params_json or ""

    for request_id, params_json, response_type, finished
        in async_iterator_factory(ctx, method, params_json) do

        if finished then
            local decoded = json.decode(params_json)

            if response_type ~= 0 then
                error(decoded, 2)
            end

            if result_field then
                return decoded[result_field]
            else
                return decoded
            end
        end
    end
end

