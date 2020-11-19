#!/usr/bin/env lua

local lib = require("tonos.client")
local context = lib.context
local net = lib.net
local config = '{"network":{"server_address":"https://net.ton.dev"}}'
local coffee_shop = "0:81236e4b0298f55b1d4d67d0f508cffa21466f42f646a829ff68ea4562f832bc"
local ctx = context.create(config)

local function get_balance(account)
    local params = {
        collection = "accounts",
        filter = { id = { eq = account } },
        result = "balance"
    }
    local result = net.query_collection(ctx, params).await().result

    return tonumber(result[1].balance, 16)
end

local balance = get_balance(coffee_shop)

print("Balance is " .. tostring(balance) .. " nanotons")

context.destroy(ctx)

return 0

