describe("a crypto test suite #crypto", function()
    local context = require "context"
    local crypto = require "crypto"
    local inspect = require "inspect"
    local tu = require "testutils"

    local ctx

    setup(function()
        local config = '{"network": {"server_address": "https://net.ton.dev"}}'

        ctx = context.create(config).handle
    end)

    teardown(function()
        context.destroy(ctx)
    end)

    describe("a crypto.nacl_sign_detached", function()
        it("should return a signature", function()
            local encoded = tu:create_encoded_message(ctx, { External = tu.keys.public })
            local secret = tu.keys.public .. tu.keys.secret
            local result = crypto.nacl_sign_detached(ctx, encoded, secret)

            assert.equals(
                "709c5b37d0749dfb9ff8068e3157940db4476ea9c8a6981ef17d2f3cc5dfb0bb339a059d6ef1cb384b7e430a99fe3ee95adfa5781607b0d04dc3b9a97106d70c",
                result.signature)
        end)
    end)

    describe("a crypto.generate_random_sign_keys", function()
        it("should return a random key pair", function()
            local result = crypto.generate_random_sign_keys(ctx)

            assert.is_not_nil(result.public)
            assert.is_not_nil(result.secret)
        end)
    end)

    describe("a crypto.mnemonic_derive_sign_keys", function()
        it("should return a derived key pair", function()
            local result = crypto.mnemonic_derive_sign_keys(
                ctx,
                "dumb hunt swamp naive range drama snake network pride bag shoot earn",
                "m/44'/396'/0'/0/0")
            local keys = {
                public = "134c67910aa0bd4410e0b62379d517af13df99ba04764bca06e0ba86c736b80a",
                secret = "ddf87be7c470ea26811e5ef86391cb97d79afb35098753c2f990c2b0aef5223d"
            }

            assert.same(keys, result)
        end)
    end)
end)

