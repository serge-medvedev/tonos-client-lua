package.path = "../client/?.lua;" .. package.path

local tc = require "tonclua"
local json = require "json"
local client = require "client"

local queries = {}

-- collection names: accounts, blocks, transactions, messages, block_signatures

function queries.query_collection(ctx, collection, filter, result, order, limit)
	local params_json = json.encode(
		{ collection = collection, filter = filter, result = result, order = order, limit = limit })
	local response_handle = tc.json_request(ctx, "queries.query_collection", params_json)
	local err, result = tc.read_json_response(response_handle)

	if err then
		error(err)
	end

	return json.decode(result)
end

function queries.subscribe_collection(ctx, collection, filter, result, callback_id, on_result)
	client.register_callback(ctx, "", callback_id, on_result)

	local params_json = json.encode(
		{ collection = collection, filter = filter, result = result, callback_id = callback_id })
	local response_handle = tc.json_request(ctx, "queries.subscribe_collection", params_json)
	local err, result = tc.read_json_response(response_handle)

	if err then
		client.unregister_callback(ctx, callback_id)

		error(err)
	end

	return json.decode(result)
end

function queries.unsubscribe(ctx, handle)
	local params_json = json.encode({ handle = handle })

	tc.json_request(ctx, "queries.unsubscribe", params_json)
end

return queries

