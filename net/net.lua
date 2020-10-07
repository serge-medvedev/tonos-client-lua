package.path = "../client/?.lua;" .. package.path

local tc = require "tonclua"
local json = require "json"
local client = require "client"

local net = {}

-- collection names: accounts, blocks, transactions, messages, block_signatures

function net.query_collection(ctx, collection, filter, result, order, limit)
	local params_json = json.encode(
		{ collection = collection, filter = filter, result = result, order = order, limit = limit })
	local response_handle = tc.json_request_sync(ctx, "net.query_collection", params_json)
	local err, result = tc.read_json_response(response_handle)

	if err then
		error(err)
	end

	return json.decode(result)
end

function net.unsubscribe(ctx, handle)
	local params_json = json.encode({ handle = handle })

	tc.json_request_sync(ctx, "net.unsubscribe", params_json)
end

function net.subscribe_collection(ctx, collection, filter, result, on_result)
	local params_json = json.encode({ collection = collection, filter = filter, result = result })

	tc.json_request(ctx, "net.subscribe_collection", params_json, on_result)
end

function net.wait_for_collection(ctx, collection, filter, result, timeout)
	local params_json = json.encode(
		{ collection = collection, filter = filter, result = result, timeout = timeout })
	local response_handle = tc.json_request_sync(ctx, "net.wait_for_collection", params_json)
	local err, result = tc.read_json_response(response_handle)

	if err then
		error(err)
	end

	return json.decode(result)
end

return net

