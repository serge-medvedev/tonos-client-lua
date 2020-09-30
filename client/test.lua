package.path = "../?.lua;" .. package.path

local context = require "context"
local client = require "client"
local inspect = require "inspect"

local config = '{"network": {"server_address": "https://net.ton.dev"}}'
local ctx = context.create(config).handle

do  print("Testing client.version")

	local result = client.version(ctx)

	assert(result.version == "1.0.0")
end

do  print("Testing client.get_api_reference")

	local result = client.get_api_reference(ctx)

	print(inspect(result))

	assert(result.version == "1.0.0")
end

context.destroy(ctx)

