local tc_await = require "tc_await"

local client = {}

function client.version(ctx)
    return tc_await(ctx, "client.version")
end

function client.get_api_reference(ctx)
    return tc_await(ctx, "client.get_api_reference")
end

return client

