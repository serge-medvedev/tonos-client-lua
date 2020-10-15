describe("a tvm test suite #tvm", function()
    local context = require "ton.context"
    local tvm = require "ton.tvm"
    local abi = require "ton.abi"
    local crypto = require "ton.crypto"
    local processing = require "ton.processing"
    local json = require "dkjson"
    local tt = require "test.tools"

    local ctx, elector_encoded

    setup(function()
        local config = '{"network": {"server_address": "https://net.ton.dev"}}'

        ctx = context.create(config)
        elector_encoded = abi.encode_account(
            ctx, { StateInit = { code = tt.elector.code, data = tt.elector.data } }).await()
    end)

    teardown(function()
        context.destroy(ctx)
    end)

    describe("a tvm.execute_message #slow #paid", function()
        it("should get wallet info", function()
            local keys = crypto.generate_random_sign_keys(ctx).await()
            local wallet_address = "0:2222222222222222222222222222222222222222222222222222222222222222"
            local encoded = abi.encode_message(
                ctx,
                { Serialized = json.decode(tt.subscription.abi) },
                nil,
                { tvc = tt.subscription.tvc },
                { function_name = "constructor",
                  input = { wallet = wallet_address }},
                { WithKeys = keys }).await()

            tt.fund_account(ctx, encoded.address)

            processing.process_message(ctx, encoded.message, nil, false).await()

            local account = tt.fetch_account(ctx, encoded.address).boc
            local message = {
                address = encoded.address,
                abi = { Serialized = json.decode(tt.subscription.abi) },
                call_set = { function_name = "getWallet" },
                signer = { WithKeys = keys }
            }
            local result = tvm.execute_message(
                ctx, { EncodingParams = message }, account, "TvmOnly").await()

            assert.equals(wallet_address, result.decoded.output.value0)
        end)

        pending("should subscribe and get subscription", function()
        end)
    end)

    describe("a tvm.execute_get", function()
        it("should return list of participants of the Elector", function()
            local result = tvm.execute_get(ctx, elector_encoded.account, "participant_list").await()

            assert.equals(2, table.getn(result[1])) -- head and tail
        end)

        it("should compute the stake returned from the Elector", function()
            local input = string.format("0x%s", string.match(tt.elector.address, "-1:([0-9a-fA-F]+)"))
            local result = tvm.execute_get(
                ctx, elector_encoded.account, "compute_returned_stake", input).await()

            assert.equal(0, tonumber(result[1], 16))
        end)

        it("should get past elections info from the Elector", function()
            local result = tvm.execute_get(ctx, elector_encoded.account, "past_elections").await()

            assert.equals(0x5eab0e74, tonumber(result[1][1][1], 16))
        end)
    end)
end)

