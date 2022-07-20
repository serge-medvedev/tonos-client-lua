describe("a client test suite #client", function()
    local lib = require "tonos.client"
    local context = lib.context
    local client = lib.client
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

            assert.equals("1.36.1", result.version)
        end)
    end)

    describe("a client.get_api_reference", function()
        it("should return the API Reference", function()
            local result = client.get_api_reference(ctx).await()

            -- print(json.encode(result, { indent = true }))

            assert.is_not_nil(result.api)
        end)
    end)

    describe("a client.build_info", function()
        it("should return the build info", function()
            local result = client.build_info(ctx).await()

            assert.is_not_nil(result.build_number)
        end)
    end)
end)

