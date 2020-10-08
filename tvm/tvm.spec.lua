pending("a tvm test suite #tvm", function()
    local context = require "context"
    local tvm = require "tvm"

    local ctx

    setup(function()
        local config = '{"network": {"server_address": "https://net.ton.dev"}}'

        ctx = context.create(config)
    end)

    teardown(function()
        context.destroy(ctx)
    end)

    describe("a tvm.estimate_fees", function()
        it("should return estimated fees", function()
        end)
    end)
end)

