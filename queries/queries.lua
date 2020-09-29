local tc = require "tonclua"
local json = require "json"

local queries = {}

function queries.query_collection(ctx, collection, filter, result, order, limit)
    local params_json = json.encode(
        { collection = collection, filter = filter, result = result, order = order, limit = limit })
    local response_handle = tc.json_request(ctx, "queries.query_collection", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

return queries

