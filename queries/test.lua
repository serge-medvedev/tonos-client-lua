package.path = "../?.lua;" .. package.path

local context = require "context"
local queries = require "queries"
local inspect = require "inspect"

function sleep(n)
	os.execute("sleep " .. tonumber(n))
end

function lookup(t, ...)
	for _, k in ipairs{...} do
		t = t[k]
		if not t then
			return nil
		end
	end

	return t
end

local config = '{"network": {"server_address": "https://main.ton.dev"}}'
local ctx = context.create(config).handle

do  print("Testing queries.query_collection")

	local addr = "0:7866e5e4edc40639331140807d2a2dc7d4bc53005bb34d71428cdd250c91b404"
	local result = queries.query_collection(ctx, "accounts", { id = { eq = addr } }, "balance")

	print(inspect(result))

	local balance = tonumber(lookup(result, "result", 1, "balance") or -1)

	assert(balance > 0)
end

do  print("Testing queries.subscribe_collection")

	local cb_calls = 0
	local on_result = function (request_id, result_json, error_json, flags)
		print(inspect({ request_id = request_id, result_json = result_json, error_json = error_json, flags = flags }))
		cb_calls = cb_calls + 1
	end
	local subscription_handle = queries.subscribe_collection(ctx, "messages", {}, "id", 0xabcd, on_result)

	sleep(10)

	queries.unsubscribe(ctx, subscription_handle)

	assert(cb_calls > 0)
end

context.destroy(ctx)

