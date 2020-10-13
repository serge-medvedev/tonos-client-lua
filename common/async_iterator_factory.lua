local tc = require "tonclua"

return function (ctx, method, params_json)
    return coroutine.wrap(function()
        local request_id, id = tc.request(ctx, method, params_json)

        while request_id ~= id do
            id = tc.fetch_response_data(request_id) -- yields on the C-side, returns request_id when finished
        end
    end)
end

