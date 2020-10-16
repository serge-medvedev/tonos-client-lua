describe("a net test suite #net", function()
    local lib = require "ton.client"
    local context = lib.context
    local net = lib.net
    local json = require "dkjson"

    local ctx

    setup(function()
        local config = '{"network": {"server_address": "https://main.ton.dev"}}'

        ctx = context.create(config)
    end)

    teardown(function()
        context.destroy(ctx)
    end)

    describe("a net.query_collection", function()
        it("should return positive account balance", function()
            local addr = "0:7866e5e4edc40639331140807d2a2dc7d4bc53005bb34d71428cdd250c91b404"
            local result = net.query_collection(ctx, "accounts", { id = { eq = addr } }, "balance").await()
            local balance = tonumber(result[1].balance, 16)

            assert.is_true(balance > 0)
        end)
    end)

    describe("a net.subscribe_collection #slow", function()
        it("should receive incoming messages being subscribed", function()
            local cb_calls, max_cb_calls, subscription_handle = 0, 3

            for request_id, params_json, response_type, finished
                in net.subscribe_collection(ctx, "messages", {}, "id") do

                cb_calls = cb_calls + 1

                if subscription_handle == nil and response_type == 0 then
                    subscription_handle = json.decode(params_json).handle
                end

                if cb_calls == max_cb_calls then
                    net.unsubscribe(ctx, subscription_handle).await() -- without this the loop is infinite
                end
            end

            assert.is_not_nil(subscription_handle)
            assert.is_true(cb_calls >= max_cb_calls) -- more events could have been queued before subscription was canceled
        end)
    end)

    describe("a net.wait_for_collection", function()
        it("should wait for an incoming message", function()
            local result = net.wait_for_collection(ctx, "messages", {}, "id", 10000).await()

            assert.is_not_nil(string.match(result.id, "^[0-9a-zA-Z]+$"))
        end)
    end)
end)

