local tc = require "tonclua"
local json = require "json"

function sleep(n)
    os.execute("sleep " .. tonumber(n))
end

local config = '{"network": {"server_address": "https://net.ton.dev"}}'
local ctx

do  print("Testing tc_create_context")

    local h = tc.create_context(config)
    local err, result = tc.read_json_response(h)

    assert(err == nil)

    ctx = json.decode(result or "{}").handle

    assert(tonumber(ctx) ~= nil)
end

do  print("Testing tc_json_request")

    local h = tc.json_request(ctx, "client.version", "{}")
    local err, result = tc.read_json_response(h)

    assert(err == nil)

    result = json.decode(result)

    assert(result.version == "1.0.0")
end

do  print("Testing tc_json_request_async")

    local request_id, result_json, error_json, flags;
    local on_response = function (request_id_, result_json_, error_json_, flags_)
        request_id = request_id_
        result_json = result_json_
        error_json = error_json_
        flags = flags_
    end

    tc.json_request_async(ctx, "client.version", "{}", 666, on_response)

    sleep(2)

    local version = json.decode(result_json or "{}").version

    assert(request_id == 666)
    assert(version == "1.0.0")
    assert(error_json == nil)
    assert(flags == 1)
end

do  print("Testing tc_destroy_context")

    tc.destroy_context(ctx)
end

