describe("a client test suite #client", function()
    local context = require "context"
    local client= require "client"
    local tu = require "testutils"

    local ctx

    setup(function()
        local config = '{"network": {"server_address": "https://net.ton.dev"}}'

        ctx = context.create(config)
    end)

    teardown(function()
        context.destroy(ctx)
    end)

    describe("a client.version", function()
        it("should return SDK version", function()
            local result = client.version(ctx)

            assert.equals("1.0.0", result.version)
        end)
    end)

    describe("a client.get_api_reference", function()
        it("should return the API Reference", function()
            local result = client.get_api_reference(ctx)

            -- print(tu.inspect(result))

            assert.is_not_nil(result.api)
        end)
    end)
end)

