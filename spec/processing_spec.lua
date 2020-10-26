describe("a processing test suite #processing #slow #paid", function()
    local lib = require "ton.client"
    local abi = lib.abi
    local context = lib.context
    local processing = lib.processing
    local crypto = lib.crypto
    local json = require "dkjson"
    local tt = require "spec.tools"

    local ctx, message_encode_params, encoded

    setup(function()
        local config = '{"network": {"server_address": "https://net.ton.dev"}}'

        ctx = context.create(config)
    end)

    before_each(function()
        local keys = crypto.generate_random_sign_keys(ctx).await()

        message_encode_params = {
            abi = { type = "Serialized", value = json.decode(tt.events.abi) },
            deploy_set = { tvc = tt.events.tvc },
            call_set = {
                function_name = "constructor",
                header = {
                    pubkey = keys.public
                }
            },
            signer = { type = "Keys", keys = keys }
        }
        encoded = abi.encode_message(ctx, message_encode_params).await()

        tt.fund_account(ctx, encoded.address)
    end)

    teardown(function()
        context.destroy(ctx)
    end)

    describe("a processing.wait_for_transaction", function()
        it("should receive a transaction confirmation", function()
            local shard_block_id
            local send_message_params = {
                message = encoded.message,
                send_events = true
            }

            for request_id, params_json, response_type, finished
                in processing.send_message(ctx, send_message_params) do

                local result = json.decode(params_json)

                if response_type == 1 then
                    error(params_decoded)
                end

                if shard_block_id == nil and response_type == 0 then
                    shard_block_id = result.shard_block_id
                end
            end

            assert.is_not_nil(string.match(shard_block_id, "^[0-9a-f]+$"))

            local finalized = false
            local wait_for_transaction_params = {
                message = encoded.message,
                shard_block_id = shard_block_id,
                send_events = true,
                abi = { type = "Serialized", value = json.decode(tt.events.abi) }
            }

            for request_id, params_json, response_type, finished
                in processing.wait_for_transaction(ctx, wait_for_transaction_params) do

                local result = json.decode(params_json)

                if response_type == 1 then
                    error(params_decoded)
                end

                if not finalized and result and result.transaction then
                    finalized = (result.transaction.status_name == "finalized")
                end
            end

            assert.is_true(finalized)
        end)
    end)

    describe("a processing.process_message", function()
        it("should process a message in stages", function()
            local finalized = false
            local process_message_params = {
                message_encode_params = message_encode_params,
                send_events = true
            }

            for request_id, params_json, response_type, finished
                in processing.process_message(ctx, process_message_params) do

                local result = json.decode(params_json)

                if response_type == 1 then
                    error(result)
                end

                if result and not DidSend then
                    DidSend = (result.type == "DidSend")
                end

                if not finalized and result and result.transaction then
                    finalized = (result.transaction.status_name == "finalized")
                end
            end

            assert.is_true(finalized)
        end)
    end)
end)

