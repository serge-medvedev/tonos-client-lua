describe("a crypto test suite", function()
    local context = require "context"
    local crypto = require "crypto"

    local ctx

    setup(function()
        local config = '{"network": {"server_address": "https://net.ton.dev"}}'

        ctx = context.create(config).handle
    end)

    teardown(function()
        context.destroy(ctx)
    end)

    describe("a crypto.mnemonic_derive_sign_keys", function()
        it("should return a key pair", function()
            local result = crypto.mnemonic_derive_sign_keys(
                ctx,
                "dumb hunt swamp naive range drama snake network pride bag shoot earn",
                "m/44'/396'/0'/0/0")
            local key_pair = {
                public = "134c67910aa0bd4410e0b62379d517af13df99ba04764bca06e0ba86c736b80a",
                secret = "ddf87be7c470ea26811e5ef86391cb97d79afb35098753c2f990c2b0aef5223d"
            }

            assert.same(result, key_pair)
        end)
    end)
end)

