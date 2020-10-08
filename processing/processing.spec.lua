describe("a processing test suite #processing", function()
    local context = require "context"
    local processing = require "processing"
    local client = require "client"
    local json = require "json"
    local tu = require "testutils"
    local inspect = require "inspect"

    local ctx, message

    setup(function()
        local config = '{"network": {"server_address": "https://net.ton.dev"}}'

        ctx = context.create(config)
        message = tu:create_encoded_message(ctx, { WithKeys = tu.keys })
    end)

    teardown(function()
        context.destroy(ctx)
    end)

    describe("a processing.send_message", function()
        it("should send a message asynchronously", function()
            local sent = false
            local shard_block_id
            local callback = function(request_id, params_json, response_type, finished)
                if 0 == response_type then
                    shard_block_id = json.decode(params_json or "{}").shard_block_id
                end

                sent = finished
            end

            processing.send_message(ctx, message, tu.abi, true, callback)

            tu.sleep(3)

            assert.is_true(sent)
            assert.is_true(string.len(shard_block_id) > 0)
        end)
    end)

    describe("a processing.wait_for_transaction", function()
        it("should wait for a transaction", function()
            local cb_calls = 0
            local callback = function(request_id, params_json, response_type, finished)
                cb_calls = cb_calls + 1
            end
            local on_sent = function(request_id, params_json, response_type, finished)
                if 0 == response_type then
                    local result = json.decode(params_json)

                    processing.wait_for_transaction(ctx, tu.abi, message, result.shard_block_id, true, callback)
                end
            end

            processing.send_message(ctx, message, tu.abi, true, callback)

            tu.sleep(3)

            assert.is_true(cb_calls > 0)
        end)
    end)

    describe("a processing.process_message", function()
        it("should process a message asynchronously", function()
            local sent = false
            local callback = function(request_id, params_json, response_type, finished)
                if json.decode(params_json or "{}").DidSend then
                    sent = true
                end
            end

            processing.process_message(ctx, { message = message, abi = tu.abi }, true, callback)

            tu.sleep(3)

            assert.is_true(sent)
        end)
    end)
end)

