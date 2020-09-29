package.path = "../?.lua;" .. package.path

local context = require "context"
local tvm = require "tvm"
local inspect = require "inspect"

local config = '{"network": {"server_address": "https://net.ton.dev"}}'
local ctx = context.create(config).handle

do
    print("Testing tvm.estimate_fees")
    local result = tvm.estimate_fees(ctx)
    assert(result)
end

