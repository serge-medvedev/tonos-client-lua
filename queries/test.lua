package.path = "../?.lua;" .. package.path

local context = require "context"
local queries = require "queries"
local inspect = require "inspect"

local config = '{"network": {"server_address": "https://net.ton.dev"}}'
local ctx = context.create(config).handle

do
    print("Testing queries.query_collection")
    local addr = "0:e745f4d86672dccd4c6270bfb23be02481aa65814a40f7edd74d3940f7a891fb"
    local result = queries.query_collection(ctx, "accounts", { id = { eq = addr } }, "balance")
    print(inspect(result))
    local balance = tonumber(result.result[1].balance)
    assert(balance > 0)
end

