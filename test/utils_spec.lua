describe("a utils test suite #utils", function()
    local lib = require "ton.client"
    local context = lib.context
    local utils = lib.utils

    local ctx

    setup(function()
        local config = '{"network": {"server_address": "https://main.ton.dev"}}'

        ctx = context.create(config)
    end)

    teardown(function()
        context.destroy(ctx)
    end)

    describe("a utils.convert_address", function()
        it("should convert the address to the format specified", function()
            local result = utils.convert_address(
                ctx,
                "0:b453e53ae4ae0d8104592c1127298aecb637bb70a0bcd56322cf7731a66ce1d2",
                { Base64 = { url = false, test = false, bounce = true } }).await()

            assert.equals("EQC0U+U65K4NgQRZLBEnKYrstje7cKC81WMiz3cxpmzh0sJJ", result.address)
        end)
    end)
end)

