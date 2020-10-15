local async = require "ton.commons.async"

local client = {}

function client.version(ctx)
    return async.iterator_factory(ctx, "client.version")
end

function client.get_api_reference(ctx)
    return async.iterator_factory(ctx, "client.get_api_reference")
end

return client

