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
	local response_handle = tc.json_request_sync(ctx, "client.version", "")

	return check_response(response_handle)
end

function client.get_api_reference(ctx)
	local response_handle = tc.json_request_sync(ctx, "client.get_api_reference", "")

	return check_response(response_handle)
end

return client

