describe("a net test suite #net", function()
    local context = require "context"
    local net = require "net"
    local tu = require "testutils"

    local ctx

    setup(function()
        local config = '{"network": {"server_address": "https://main.ton.dev"}}'

        ctx = context.create(config).handle
    end)

    teardown(function()
        context.destroy(ctx)
    end)

    -- collection names: accounts, blocks, transactions, messages, block_signatures

    describe("a net.query_collection", function()
        it("should return positive account balance", function()
            local addr = "0:7866e5e4edc40639331140807d2a2dc7d4bc53005bb34d71428cdd250c91b404"
            local result = net.query_collection(ctx, "accounts", { id = { eq = addr } }, "balance")
            local balance = tonumber(tu.lookup(result, "result", 1, "balance") or -1)

            assert.is_true(balance > 0)
        end)
    end)

    describe("a net.subscribe_collection", function()
        it("should receive incoming messages being subscribed", function()
            local cb_calls = 0
            local on_result = function (request_id, result_json, error_json, flags)
                cb_calls = cb_calls + 1
            end
            local subscription_handle = net.subscribe_collection(
                ctx, "messages", {}, "id", on_result)

            tu.sleep(10) -- time enough to receive some messages

            net.unsubscribe(ctx, subscription_handle)

            assert.is_true(cb_calls > 0)
        end)
    end)

    describe("a net.wait_for_collection", function()
        it("should wait for an incoming message", function()
            local result = net.wait_for_collection(ctx, "messages", {}, "id", 10000)
            local id = tu.lookup(result, "result", "id")

            assert.is_not_nil(id)
        end)
    end)
end)

