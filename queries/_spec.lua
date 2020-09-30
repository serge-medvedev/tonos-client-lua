describe("a queries test suite", function()
    local context = require "context"
    local queries = require "queries"

    function sleep(n)
        os.execute("sleep " .. tonumber(n))
    end

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
        local config = '{"network": {"server_address": "https://main.ton.dev"}}'

        ctx = context.create(config).handle
    end)

    teardown(function()
        context.destroy(ctx)
    end)

    -- collection names: accounts, blocks, transactions, messages, block_signatures

    describe("a queries.query_collection", function()
        it("should return positive account balance", function()
            local addr = "0:7866e5e4edc40639331140807d2a2dc7d4bc53005bb34d71428cdd250c91b404"
            local result = queries.query_collection(ctx, "accounts", { id = { eq = addr } }, "balance")
            local balance = tonumber(lookup(result, "result", 1, "balance") or -1)

            assert.is_true(balance > 0)
        end)
    end)

    describe("a queries.subscribe_collection", function()
        it("should receive incoming messages being subscribed", function()
            local cb_calls = 0
            local on_result = function (request_id, result_json, error_json, flags)
                cb_calls = cb_calls + 1
            end
            local subscription_handle = queries.subscribe_collection(
                ctx, "messages", {}, "id", 0xabcd, on_result)

            sleep(10) -- time enough to receive some messages

            queries.unsubscribe(ctx, subscription_handle)

            assert.is_true(cb_calls > 0)
        end)
    end)
end)

