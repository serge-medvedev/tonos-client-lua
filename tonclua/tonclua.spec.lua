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
        local err, result = tc.read_string(h)

        ctx = json.decode(result or "{}").result

        it("should return a context handle", function()
            assert.is_nil(err)
            assert.is_true(ctx > 0)
        end)
    end)

    describe("a tc_request", function()
        local h = tc.request_sync(ctx, "client.version", "{}")
        local _, result = tc.read_string(h)
        local decoded = json.decode(result).result

        it("should return SDK version", function()
            assert.equals(decoded.version, "1.0.0")
        end)
    end)

    describe("a tc_request_async", function()
        it("should accept and invoke a callback", function()
            local request_id, params_json, response_type, finished
            local on_response = function (request_id_, params_json_, response_type_, finished_)
                if response_type_ == 0 then
                    request_id = request_id_
                    params_json = params_json_
                    response_type = response_type_
                    finished = finished_
                end
            end
            local rid = tc.request(ctx, "client.version", "{}", on_response)

            sleep(3)

            local version = json.decode(params_json or "{}").version

            assert.same(request_id, rid)
            assert.equals("1.0.0", version)
            assert.equals(0, response_type)
            assert.is_true(finished)
        end)
    end)
end)

