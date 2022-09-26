describe("a tvm test suite #tvm", function()
    local lib = require "tonos.client"
    local context = lib.context
    local tvm = lib.tvm
    local abi = lib.abi
    local crypto = lib.crypto
    local processing = lib.processing
    local json = require "dkjson"
    local tt = require "spec.tools"

    local ctx, elector_encoded

    setup(function()
        local config = '{"network": {"server_address": "https://devnet.evercloud.dev/d61ac7417de44bdbb5446a4efe0690c7"}}'

        ctx = context.create(config)
        elector_encoded = abi.encode_account(ctx, {
            state_init = {
                type = "StateInit",
                code = tt.data.elector.code,
                data = tt.data.elector.data
            }
        }).await()
    end)

    teardown(function()
        context.destroy(ctx)
    end)

    describe("heavy tvm.run_* methods #slow #paid", function()
        it("should subscribe and check subscription", function()
            local subscription_abi = { type = "Json", value = tt.data.subscription.abi }
            local signer = {
                type = "Keys",
                keys = crypto.generate_random_sign_keys(ctx).await()
            }
            local wallet_address = "0:2222222222222222222222222222222222222222222222222222222222222222"
            local encode_message_params = {
                abi = subscription_abi,
                deploy_set = { tvc = tt.data.subscription.tvc },
                call_set = {
                    function_name = "constructor",
                    input = { wallet = wallet_address }
                },
                signer = signer
            }
            local encoded = abi.encode_message(ctx, encode_message_params).await()

            tt.fund_account(ctx, encoded.address)

            local account = tt.fetch_account(ctx, encoded.address).boc
            local subscribe_params = {
                subscriptionId = "0x1111111111111111111111111111111111111111111111111111111111111111",
                pubkey = "0x2222222222222222222222222222222222222222222222222222222222222222",
                to = "0:3333333333333333333333333333333333333333333333333333333333333333",
                value = "0x123",
                period = "0x456",
            }

            encode_message_params = {
                abi = subscription_abi,
                address = encoded.address,
                deploy_set = { tvc = tt.data.subscription.tvc },
                call_set = {
                    function_name = "subscribe",
                    input = subscribe_params
                },
                signer = signer
            }
            encoded = abi.encode_message(ctx, encode_message_params).await()

            local run_executor_params = {
                message = encoded.message,
                abi = subscription_abi,
                account = {
                    type = "Account",
                    boc = account
                }
            }
            local result = tvm.run_executor(ctx, run_executor_params).await()

            assert.equals(encoded.message_id, result.transaction.in_msg)
            assert.is_true(result.fees.total_account_fees > 0)

            account = result.account
            encode_message_params = {
                abi = subscription_abi,
                address = encoded.address,
                call_set = {
                    function_name = "getSubscription",
                    input = { subscriptionId = subscribe_params.subscriptionId }
                },
                signer = signer
            }
            encoded = abi.encode_message(ctx, encode_message_params).await()

            local run_tvm_params = {
                abi = subscription_abi,
                account = account,
                message = encoded.message
            }

            result = tvm.run_tvm(ctx, run_tvm_params).await().decoded

            assert.equals(subscribe_params.pubkey, result.output.value0.pubkey)
        end)
    end)

    describe("a tvm.run_get", function()
        it("should return list of participants of the Elector", function()
            local run_get_params = {
                account = elector_encoded.account,
                function_name = "participant_list"
            }
            local result = tvm.run_get(ctx, run_get_params).await().output

            assert.equals(2, table.getn(result[1])) -- head and tail
        end)

        it("should compute the stake returned from the Elector", function()
            local run_get_params = {
                account = elector_encoded.account,
                function_name = "compute_returned_stake",
                input = string.format("0x%s", string.match(tt.data.elector.address, "-1:([0-9a-fA-F]+)"))
            }
            local result = tvm.run_get(ctx, run_get_params).await().output

            assert.equal(0, tonumber(result[1]))
        end)

        it("should get past elections info from the Elector", function()
            local run_get_params = {
                account = elector_encoded.account,
                function_name = "past_elections"
            }
            local result = tvm.run_get(ctx, run_get_params).await().output

            assert.equals(1588268660, tonumber(result[1][1][1]))
        end)
    end)
end)

