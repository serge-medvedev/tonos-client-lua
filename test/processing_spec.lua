describe("a processing test suite #processing #slow #paid", function()
    local lib = require "ton.client"
    local context = lib.context
    local processing = lib.processing
    local crypto = lib.crypto
    local json = require "dkjson"
    local tt = require "test.tools"

    local ctx, encoded

    setup(function()
        local config = '{"network": {"server_address": "https://net.ton.dev"}}'

        ctx = context.create(config)
    end)

    before_each(function()
        local keys = crypto.generate_random_sign_keys(ctx).await()

        encoded = tt.create_encoded_message(ctx, { WithKeys = keys })

        tt.fund_account(ctx, encoded.address)
    end)

    teardown(function()
        context.destroy(ctx)
    end)

    describe("a processing.send_message", function()
        it("should send a message and receive a sequence of responses", function()
            local sent, shard_block_id = false
            local send_message_params = {
                message = encoded.message,
                abi = tt.abi,
                send_events = true
            }

            for request_id, params_json, response_type, finished
                in processing.send_message(ctx, send_message_params) do

                if shard_block_id == nil and response_type == 0 then
                    shard_block_id = json.decode(params_json).shard_block_id
                end

                sent = finished
            end

            assert.is_true(sent)
            assert.is_not_nil(string.match(shard_block_id, "^[0-9a-f]+$"))
        end)
    end)

    describe("a processing.wait_for_transaction", function()
        it("should receive a transaction confirmation", function()
            local shard_block_id
            local send_message_params = {
                message = encoded.message,
                abi = tt.abi,
                send_events = true
            }

            for request_id, params_json, response_type, finished
                in processing.send_message(ctx, send_message_params) do

                if shard_block_id == nil and response_type == 0 then
                    shard_block_id = json.decode(params_json).shard_block_id

                    break
                end
            end

            local received = false
            local wait_for_transaction_params = {
                message = encoded.message,
                abi = tt.abi,
                shard_block_id = shard_block_id,
                send_events = true
            }

            for request_id, params_json, response_type, finished
                in processing.wait_for_transaction(ctx, wait_for_transaction_params) do

                local result = json.decode(params_json)

                if result and not received then
                    received = result.TransactionReceived ~= nil
                end
            end

            assert.is_true(received)
        end)
    end)

    describe("a processing.process_message", function()
        it("should process a message in stages", function()
            local DidSend, TransactionReceived
            local process_message_params = {
                message = { Encoded = { message = encoded.message, abi = tt.abi } },
                send_events = true
            }

            for request_id, params_json, response_type, finished
                in processing.process_message(ctx, process_message_params) do

                local result = json.decode(params_json)

                if result and not DidSend then
                    DidSend = result.DidSend ~= nil
                end

                if result and not TransactionReceived then
                    TransactionReceived = result.TransactionReceived ~= nil
                end
            end

            assert.is_true(DidSend)
            assert.is_true(TransactionReceived)
        end)
    end)
end)

