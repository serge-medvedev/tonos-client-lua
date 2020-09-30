local tc = require "tonclua"
local json = require "json"

function check_response(response_handle)
	local err, result = tc.read_json_response(response_handle)

	if err then
		error(err)
	end

	return json.decode(result)
end

local client = {}

function client.version(ctx)
	local response_handle = tc.json_request(ctx, "client.version", "")

	return check_response(response_handle)
end

function client.get_api_reference(ctx)
	local response_handle = tc.json_request(ctx, "client.get_api_reference", "")

	return check_response(response_handle)
end

function client.register_callback(ctx, params_json, request_id, on_result)
	tc.json_request_async(ctx, "client.register_callback", params_json, request_id, on_result)
end

function client.unregister_callback(ctx, callback_id)
	local params_json = json.encode({ callback_id = callback_id })
	local response_handle = tc.json_request(ctx, "client.unregister_callback", params_json)

	return check_response(response_handle)
end

return client

