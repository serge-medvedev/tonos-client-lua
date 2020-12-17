describe("a net test suite #net", function()
    local json = require "dkjson"
    local sched = require "lumen.sched"
    local tt = require "spec.tools"
    local lib = require "tonos.client"
    local abi, context, crypto, net, processing = lib.abi, lib.context, lib.crypto, lib.net, lib.processing

    local ctx

    setup(function()
        local config = '{"network": {"server_address": "https://main.ton.dev"}}'

        ctx = context.create(config)
    end)

    teardown(function()
        context.destroy(ctx)
    end)

    describe("a net.query", function()
        it("should perform a graphql query the same way playground does", function()
            local result = net.query(ctx, { query = "query{info{version}}"}).await().result

            assert.is_not_nil(string.match(result.data.info.version, "[0-9]+\.[0-9]+\.[0-9]+"))
        end)
    end)

    describe("suspending and resuming of net operations #slow #paid #susres", function()
        local main_ctx, sub_ctx, keys, message_encode_params, msg

        setup(function()
            local config = '{"network": {"server_address": "https://net.ton.dev"}}'

            main_ctx = context.create(config)
            sub_ctx = context.create(config)

            keys = crypto.generate_random_sign_keys(main_ctx).await()
            message_encode_params = {
                abi = { type = "Json", value = tt.data.hello.abi },
                deploy_set = { tvc = tt.data.hello.tvc },
                call_set = { function_name = "constructor" },
                signer = { type = "Keys", keys = keys }
            }
            msg = abi.encode_message(main_ctx, message_encode_params).await()
        end)

        teardown(function()
            context.destroy(sub_ctx)
            context.destroy(main_ctx)
        end)

        local function subscribe_collection(txs)
            local subscribe_collection_params = {
                collection = "transactions",
                filter = {
                    account_addr = { eq = msg.address },
                    status = { eq = 3 } -- Finalized
                },
                result = "id account_addr"
            }
            local subscription_handle

            for request_id, params_json, response_type, finished
                in net.subscribe_collection(sub_ctx, subscribe_collection_params) do

                -- print(json.encode({
                --     request_id = request_id,
                --     params_json = params_json,
                --     response_type = response_type,
                --     finished = finished
                -- }, { indent = true }))

                local params = json.decode(params_json)

                if response_type == 0 then
                    subscription_handle = params.handle

                    sched.schedule_signal("subscription_handle", subscription_handle)
                elseif params and params.result then
                    assert.equals(msg.address, params.result.account_addr)

                    table.insert(txs, params.result)
                end

                sched.wait()
            end
        end

        local function check(txs)
            local _, subscription_handle = sched.wait({ "subscription_handle" })

            -- this transaction is gonna be recorded
            tt.fund_account(main_ctx, msg.address)

            net.suspend(sub_ctx).await()

            sched.wait()

            -- this transaction is NOT gonna be recorded due to network operations being suspended
            processing.process_message(main_ctx, {
                message_encode_params = message_encode_params,
                send_events = false
            }).await()

            assert.equals(1, #txs)

            net.resume(sub_ctx).await()

            -- this transaction is gonna be recorded since network operations are resumed
            processing.process_message(main_ctx, {
                message_encode_params = {
                    abi = { type = "Json", value = tt.data.hello.abi },
                    address = msg.address,
                    call_set = { function_name = "touch" },
                    signer = { type = "Keys", keys = keys }
                },
                send_events = false
            }).await()

            sched.wait()

            -- two different transactions recorded
            assert.equals(2, #txs)
            assert.is_not_equal(txs[1].id, txs[2].id)

            net.unsubscribe(sub_ctx, { handle = subscription_handle }).await()
        end

        it("subscribes to transactions with addresses", function()
            local txs = {}

            sched.run(function()
                subscribe_collection(txs)
            end)
            sched.run(function()
                check(txs)
            end)
            sched.loop()
        end)
    end)

    describe("a net.query_collection", function()
        it("should return positive account balance", function()
            local addr = "0:7866e5e4edc40639331140807d2a2dc7d4bc53005bb34d71428cdd250c91b404"
            local query_collection_params = {
                collection = "accounts",
                filter = { id = { eq = addr } },
                result = "balance"
            }
            local result = net.query_collection(ctx, query_collection_params).await().result
            local balance = tonumber(result[1].balance, 16)

            assert.is_true(balance > 0)
        end)
    end)

    describe("a net.subscribe_collection #slow", function()
        it("should receive incoming messages being subscribed", function()
            local cb_calls, max_cb_calls, subscription_handle = 0, 3
            local subscribe_collection_params = {
                collection = "messages",
                result = "id"
            }

            for request_id, params_json, response_type, finished
                in net.subscribe_collection(ctx, subscribe_collection_params) do

                cb_calls = cb_calls + 1

                if subscription_handle == nil and response_type == 0 then
                    subscription_handle = json.decode(params_json).handle
                end

                if cb_calls == max_cb_calls then
                    net.unsubscribe(ctx, { handle = subscription_handle }).await() -- without this the loop is infinite
                end
            end

            assert.is_not_nil(subscription_handle)
            assert.is_true(cb_calls >= max_cb_calls) -- more events could have been queued before subscription was canceled
        end)
    end)

    describe("a net.wait_for_collection", function()
        it("should wait for an incoming message", function()
            local wait_for_collection_params = {
                collection = "messages",
                result = "id",
                timeout = 10000
            }
            local result = net.wait_for_collection(ctx, wait_for_collection_params).await().result

            assert.is_not_nil(string.match(result.id, "^[0-9a-f]+$"))
        end)
    end)
end)

