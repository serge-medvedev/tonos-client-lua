describe("a tonclua test suite #tonclua", function()
    local tc = require "tonclua"
    local json = require "json"

    function sleep(n)
        os.execute("sleep " .. tonumber(n))
    end

    local ctx

    teardown(function()
        tc.destroy_context(ctx)
    end)

    describe("a tc_create_context", function()
        local config = '{"network": {"server_address": "https://net.ton.dev"}}'
        local h = tc.create_context(config)
        local err, result = tc.read_json_response(h)

        ctx = json.decode(result or "{}").handle

        it("should return a context handle", function()
            assert.is_nil(err)
            assert.equals(ctx, 1)
        end)
    end)

    describe("a tc_json_request", function()
        local h = tc.json_request(ctx, "client.version", "{}")
        local err, result = tc.read_json_response(h)

        result = json.decode(result)

        it("should return SDK version", function()
            assert.is_nil(err)
            assert.equals(result.version, "1.0.0")
        end)
    end)

    describe("a tc_json_request_async", function()
        it("should accept and invoke a callback", function()
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

            assert.equals(request_id, 666)
            assert.equals(version, "1.0.0")
            assert.is_nil(error_json)
            assert.equals(flags, 1)
        end)
    end)
end)

