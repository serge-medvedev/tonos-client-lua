describe("a tvm test suite #tvm", function()
    local lib = require "ton.client"
    local context = lib.context
    local tvm = lib.tvm
    local abi = lib.abi
    local crypto = lib.crypto
    local processing = lib.processing
    local json = require "dkjson"
    local tt = require "test.tools"

    local ctx, elector_encoded

    setup(function()
        local config = '{"network": {"server_address": "https://net.ton.dev"}}'

        ctx = context.create(config)
        elector_encoded = abi.encode_account(ctx, {
            state_init = { StateInit = { code = tt.elector.code, data = tt.elector.data } }
        }).await()
    end)

    teardown(function()
        context.destroy(ctx)
    end)

    describe("a tvm.execute_message #slow #paid", function()
        it("should get wallet info", function()
            local keys = crypto.generate_random_sign_keys(ctx).await()
            local wallet_address = "0:2222222222222222222222222222222222222222222222222222222222222222"
            local encode_message_params = {
                abi = { Serialized = json.decode(tt.subscription.abi) },
                deploy_set = { tvc = tt.subscription.tvc },
                call_set = {
                    function_name = "constructor",
                    input = { wallet = wallet_address }
                },
                signer = { WithKeys = keys }
            }
            local encoded = abi.encode_message(ctx, encode_message_params).await()

            tt.fund_account(ctx, encoded.address)

            local process_message_params = {
                message = { Encoded = { message = encoded.message } },
                send_events = false
            }

            processing.process_message(ctx, process_message_params).await()

            local execute_message_params = {
                message = {
                    EncodingParams = {
                        address = encoded.address,
                        abi = { Serialized = json.decode(tt.subscription.abi) },
                        call_set = { function_name = "getWallet" },
                        signer = { WithKeys = keys }
                    }
                },
                account = tt.fetch_account(ctx, encoded.address).boc,
                mode = "TvmOnly"
            }
            local result = tvm.execute_message(ctx, execute_message_params).await()

            assert.equals(wallet_address, result.decoded.output.value0)
        end)

        pending("should subscribe and get subscription", function()
        end)
    end)

    describe("a tvm.execute_get", function()
        it("should return list of participants of the Elector", function()
            local execute_get_params = {
                account = elector_encoded.account,
                function_name = "participant_list"
            }
            local result = tvm.execute_get(ctx, execute_get_params).await()

            assert.equals(2, table.getn(result[1])) -- head and tail
        end)

        it("should compute the stake returned from the Elector", function()
            local execute_get_params = {
                account = elector_encoded.account,
                function_name = "compute_returned_stake",
                input = string.format("0x%s", string.match(tt.elector.address, "-1:([0-9a-fA-F]+)"))
            }
            local result = tvm.execute_get(ctx, execute_get_params).await()

            assert.equal(0, tonumber(result[1], 16))
        end)

        it("should get past elections info from the Elector", function()
            local execute_get_params = {
                account = elector_encoded.account,
                function_name = "past_elections"
            }
            local result = tvm.execute_get(ctx, execute_get_params).await()

            assert.equals(0x5eab0e74, tonumber(result[1][1][1], 16))
        end)
    end)
end)

