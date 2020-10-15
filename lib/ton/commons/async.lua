local tc = require "tonclua"
local json = require "dkjson"

local async = {}

function async.iterator_factory(ctx, method, params_json)
    local request_id = tc.request(
        ctx, method, json.encode(params_json) or "")
    local meta = {
        __call = coroutine.wrap(function()
            local id

            while request_id ~= id do
                id = tc.fetch_response_data(request_id) -- yields on the C-side, returns request_id when finished
            end
        end)
    }
    local iterator_factory = setmetatable({}, meta)
    local result_path = {}

    function iterator_factory.pick(...)
        result_path = { ... }

        return iterator_factory
    end

    function iterator_factory.await()
        for request_id, params_json, response_type, finished in iterator_factory do
            if finished then
                local decoded = json.decode(params_json)

                if response_type == 1 then
                    error(decoded, 2) -- blame the caller
                end

                for _, p in ipairs(result_path) do
                    if (decoded[p] == nil) then return end

                    decoded = decoded[p]
                end

                return decoded
            end
        end
    end

    return iterator_factory
end

return async

