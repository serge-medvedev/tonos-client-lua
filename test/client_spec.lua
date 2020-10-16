describe("a client test suite #client", function()
    local context = require "ton.context"
    local client= require "ton.client"
    local json = require "dkjson"

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
            local result = client.version(ctx).await()

            assert.equals("1.0.0", result.version)
        end)
    end)

    describe("a client.get_api_reference", function()
        it("should return the API Reference", function()
            local result = client.get_api_reference(ctx).await()

            -- print(json.encode(result, { indent = true }))

            assert.is_not_nil(result.api)
        end)
    end)
end)
