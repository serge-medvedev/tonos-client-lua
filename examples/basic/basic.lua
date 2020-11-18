#!/usr/bin/env lua

local lib = require("tonos.client")
local context = lib.context
local client = lib.client
local config = '{"network":{"server_address":"https://net.ton.dev"}}'
local ctx = context.create(config)
local result = client.version(ctx).await()

print(result.version)

