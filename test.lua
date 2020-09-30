local tc = require "tonclua"
local json = require "json"

function sleep(n)
    os.execute("sleep " .. tonumber(n))
end

local config = '{"network": {"server_address": "https://net.ton.dev"}}'

do
    print("Testing tc_create_context")
    local ctx = tc.create_context(config)
    local err, result = tc.read_json_response(ctx)
    result = json.decode(result)
    assert(nil == err and 1 == result.handle)
end

do
    print("Testing tc_json_request")
    local h = tc.json_request(1, "client.version", "{}")
    local err, result = tc.read_json_response(h)
    result = json.decode(result)
    assert(nil == err and "1.0.0" == result.version)
end

do
    print("Testing tc_json_request_async")
    local request_id, result_json, error_json, flags;
    local on_response = function (request_id_, result_json_, error_json_, flags_)
        request_id = request_id_
        result_json = result_json_
        error_json = error_json_
        flags = flags_
    end

    tc.json_request_async(1, "client.version", "{}", 666, on_response)

    sleep(2)

    local version = json.decode(result_json or "{}").version

    assert(666 == request_id and "1.0.0" == version and nil == error_json and 1 == flags)
end

do
    print("Testing tc_destroy_context")
    tc.destroy_context(1)
end

