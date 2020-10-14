local async = require "ton.commons.async"

local client = {}

function client.version(ctx)
    return async.wait(ctx, "client.version")
end

function client.get_api_reference(ctx)
    return async.wait(ctx, "client.get_api_reference")
end

return client

