describe("a processing test suite #processing #slow", function()
    local context = require "context"
    local processing = require "processing"
    local client = require "client"
    local crypto = require "crypto"
    local json = require "dkjson"
    local tu = require "testutils"

    local ctx, encoded

    setup(function()
        local config = '{"network": {"server_address": "https://net.ton.dev"}}'

        ctx = context.create(config)
    end)

    before_each(function()
        local keys = crypto.generate_random_sign_keys(ctx)

        encoded = tu:create_encoded_message(ctx, { WithKeys = keys })

        tu:fund_account(ctx, encoded.address)
    end)

    teardown(function()
        context.destroy(ctx)
    end)

    describe("a processing.send_message", function()
        it("should send a message and receive a sequence of responses", function()
            local sent, shard_block_id = false

            for request_id, params_json, response_type, finished
                in processing.send_message(ctx, encoded.message, tu.abi, true) do

                if shard_block_id == nil and response_type == 0 then
                    shard_block_id = json.decode(params_json).shard_block_id
                end

                sent = finished
            end

            assert.is_true(sent)
            assert.is_not_nil(string.match(shard_block_id, "^[0-9a-zA-Z]+$"))
        end)
    end)

    describe("a processing.wait_for_transaction", function()
        it("should receive a transaction confirmation", function()
            local shard_block_id

            for request_id, params_json, response_type, finished
                in processing.send_message(ctx, encoded.message, tu.abi, true) do

                if shard_block_id == nil and response_type == 0 then
                    shard_block_id = json.decode(params_json).shard_block_id

                    break
                end
            end

            local received = false

            for request_id, params_json, response_type, finished
                in processing.wait_for_transaction(ctx, tu.abi, encoded.message, shard_block_id, true) do

                local succeeded, result = pcall(json.decode, params_json)

                if succeeded and not received then
                    received = result.TransactionReceived ~= nil
                end
            end

            assert.is_true(received)
        end)
    end)

    describe("a processing.process_message", function()
        it("should process a message in stages", function()
            local DidSend, TransactionReceived

            for request_id, params_json, response_type, finished
                in processing.process_message(ctx, { message = encoded.message, abi = tu.abi }, true) do

                local succeeded, result = pcall(json.decode, params_json)

                if succeeded and not DidSend then
                    DidSend = result.DidSend ~= nil
                end

                if succeeded and not TransactionReceived then
                    TransactionReceived = result.TransactionReceived ~= nil
                end
            end

            assert.is_true(DidSend)
            assert.is_true(TransactionReceived)
        end)
    end)
end)

