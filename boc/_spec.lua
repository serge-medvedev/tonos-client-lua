describe("a boc test suite", function()
    local context = require "context"
    local boc = require "boc"

    function lookup(t, ...)
        for _, k in ipairs{...} do
            t = t[k]
            if not t then
                return nil
            end
        end

        return t
    end

    local ctx

    setup(function()
        local config = '{"network": {"server_address": "https://net.ton.dev"}}'
        
        ctx = context.create(config).handle
    end)

    teardown(function()
        context.destroy(ctx)
    end)

    describe("a boc.parse_message", function()
        it("should return a parsed value", function()
            local result = boc.parse_message(
                ctx,"te6ccgEBAQEAXgAAt0gB/PsFspR1bdPkaI977UhHxBvawyoDizKfgwSkeV23aPsAHhm5eTtxAY5MxFAgH0qLcfUvFMAW7NNcUKM3SUMkbQEcTyeKvZiAAAYUWGAAAAmASvR6yL7WlMRA")
            local parsed_value = lookup(result,"parsed", "value")

            assert.equals(parsed_value, "0x13c9e2af662000")
        end)
    end)
end)

