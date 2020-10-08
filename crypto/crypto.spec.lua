describe("a crypto test suite #crypto", function()
    local context = require "context"
    local crypto = require "crypto"
    local tu = require "testutils"

    function count_words(s)
        local _, n = string.gsub(s, "%S+", "")

        return n
    end

    local ctx, signed_message, unsigned_message

    setup(function()
        local config = '{"network": {"server_address": "https://net.ton.dev"}}'

        ctx = context.create(config)
        unsigned_message = tu:create_encoded_message(ctx, { External = tu.keys.public })
        signed_message = "/OE+67uuV/OHBFkVq0PLxUu7oWUlnV3TdEzjlnkz8yC5i5blGQDuxgJxR81idAwpASeHXhFW82YoojRbotKmBLXunHIBAhcBAANoAAKniABnZBHo62O5aNgkdvrHxcq27e5QqqlPEJBFusYHFDUhTBGRNMZ5EKoL1EEOC2I3nVF68T35m6BHZLygbguobHNrgKAAABdGcly4NfVcxkaLVfP4BgEBAcACAgPPIAUDAQHeBAAD0CAAQdiaYzyIVQXqIIcFsRvOqL14nvzN0COyXlA3BdQ2ObXAVAIm/wD0pCAiwAGS9KDhiu1TWDD0oQkHAQr0pCD0oQgAAAIBIAwKAcj/fyHtRNAg10nCAY4Q0//TP9MA0X/4Yfhm+GP4Yo4Y9AVwAYBA9A7yvdcL//hicPhjcPhmf/hh4tMAAY4dgQIA1xgg+QEB0wABlNP/AwGTAvhC4iD4ZfkQ8qiV0wAB8nri0z8BCwBqjh74QyG5IJ8wIPgjgQPoqIIIG3dAoLnekvhj4IA08jTY0x8B+CO88rnTHwHwAfhHbpLyPN4CASASDQIBIA8OAL26i1Xz/4QW6ONe1E0CDXScIBjhDT/9M/0wDRf/hh+Gb4Y/hijhj0BXABgED0DvK91wv/+GJw+GNw+GZ/+GHi3vhG8nNx+GbR+AD4QsjL//hDzws/+EbPCwDJ7VR/+GeAIBIBEQAOW4gAa1vwgt0cJ9qJoaf/pn+mAaL/8MPwzfDH8MW99IMrqaOh9IG/o/CKQN0kYOG98IV15cDJ8AGRk/YIQZGfChGdGggQH0AAAAAAAAAAAAAAAAAAgZ4tkwIBAfYAYfCFkZf/8IeeFn/wjZ4WAZPaqP/wzwAMW5k8Ki3wgt0cJ9qJoaf/pn+mAaL/8MPwzfDH8MW9rhv/K6mjoaf/v6PwAZEXuAAAAAAAAAAAAAAAACGeLZ8DnyOPLGL0Q54X/5Lj9gBh8IWRl//wh54Wf/CNnhYBk9qo//DPACAUgWEwEJuLfFglAUAfz4QW6OE+1E0NP/0z/TANF/+GH4Zvhj+GLe1w3/ldTR0NP/39H4AMiL3AAAAAAAAAAAAAAAABDPFs+Bz5HHljF6Ic8L/8lx+wDIi9wAAAAAAAAAAAAAAAAQzxbPgc+SVviwSiHPC//JcfsAMPhCyMv/+EPPCz/4Rs8LAMntVH8VAAT4ZwBy3HAi0NYCMdIAMNwhxwCS8jvgIdcNH5LyPOFTEZLyO+HBBCKCEP////28sZLyPOAB8AH4R26S8jze"
    end)

    teardown(function()
        context.destroy(ctx)
    end)

    describe("a crypto.hdkey_derive_from_xprv_path", function()
        it("should return a derived xprv", function()
            local xprv = "xprv9s21ZrQH143K3PBHjRFACygw9K1AA8k2jTRkEDbuHX8MfTP4XxifWQj1xqqxsk8tkxCNgkJGQZUz8R5zQytHL3Kkco5WAhDB89i9r38DBrt"
            local derived_xprv = "xprvA34PuqhZ7YpNA6kJHPV6xwo78p7z9GbGYEogQLvvMRu2UaoLN3CYDT6bkC9LdavcHrBuyoncoTjQVqCAWjXakP2emHxjM4gEJ2ixtUsBZQz"
            local result = crypto.hdkey_derive_from_xprv_path(ctx, xprv, "m/44'/396'/0'/0/0")

            assert.equals(derived_xprv, result.xprv)
        end)
    end)

    describe("a crypto.nacl_box", function()
        it("should return an encrypted data", function()
            local nonce = "8618a02d351f0ce5f6bc0f56674e977a6a896a2cbb35d279" -- must be a 24-byte hex string
            local their_public = "9950d2f1a3cee9fcbc6614aba64636215c31edee31061de77c93d2fa62a67732"
            local keys = {
                public = "b8e902c15096bf030fc8a0b3549bca15ca4bc74c3612964a72d93a2b00420308",
                secret = "c9332e3f09c8de109122ea7ce992e579e475f7b1ae8d70a0e2bd911f8ffb0ec4"
            }
            local result = crypto.nacl_box(ctx, "VE9OIFNESyB2MS4wLjA=", nonce, their_public, keys.secret)

            assert.equals("GcIo9A7BWvjvmacO6iNDk5pPUFs6jY43T8mkzoKC", result.encrypted)
        end)
    end)

    describe("a crypto.hdkey_public_from_xprv", function()
        it("should return a public key", function()
            local xprv = "xprv9s21ZrQH143K3PBHjRFACygw9K1AA8k2jTRkEDbuHX8MfTP4XxifWQj1xqqxsk8tkxCNgkJGQZUz8R5zQytHL3Kkco5WAhDB89i9r38DBrt"
            local public = "033675d6aaa8ebef3adab9ac79af58eb975b10dd46067c904747018b46bc88f956"
            local result = crypto.hdkey_public_from_xprv(ctx, xprv)

            assert.equals(public, result.public)
        end)
    end)

    describe("a crypto.nacl_sign_detached", function()
        it("should return a signature", function()
            local unsigned_message = tu:create_encoded_message(
                ctx, { External = tu.keys.public }, 1599458364291, 1599458404)
            local secret = tu.keys.secret .. tu.keys.public
            local result = crypto.nacl_sign_detached(ctx, unsigned_message, secret)

            assert.equals(
                "fce13eebbbae57f387045915ab43cbc54bbba165259d5dd3744ce3967933f320b98b96e51900eec6027147cd62740c290127875e1156f36628a2345ba2d2a604",
                result.signature)
        end)
    end)

    describe("a crypto.mnemonic_from_random", function()
        it("should return a mnemonic phrase", function()
            local word_count = 12
            local result = crypto.mnemonic_from_random(ctx, 1, word_count)

            assert.equals(word_count, count_words(result.phrase))
        end)
    end)

    describe("a crypto.generate_random_sign_keys", function()
        it("should return a random key pair", function()
            local result = crypto.generate_random_sign_keys(ctx)

            assert.is_not_nil(result.public)
            assert.is_not_nil(result.secret)
        end)
    end)

    describe("a crypto.nacl_box_keypair", function()
        it("should return a random key pair", function()
            local result = crypto.nacl_box_keypair(ctx)

            assert.is_not_nil(result.public)
            assert.is_not_nil(result.secret)
        end)
    end)

    describe("a crypto.nacl_sign_keypair_from_secret_key", function()
        it("should return a signed key pair", function()
            local keys = {
                public = "134c67910aa0bd4410e0b62379d517af13df99ba04764bca06e0ba86c736b80a",
                secret = "ddf87be7c470ea26811e5ef86391cb97d79afb35098753c2f990c2b0aef5223d134c67910aa0bd4410e0b62379d517af13df99ba04764bca06e0ba86c736b80a"
            }
            local result = crypto.nacl_sign_keypair_from_secret_key(ctx, tu.keys.secret)

            assert.same(keys, result)
        end)
    end)

    describe("a crypto.hdkey_secret_from_xprv", function()
        it("should return a secret key", function()
            local xprv = "xprv9s21ZrQH143K3PBHjRFACygw9K1AA8k2jTRkEDbuHX8MfTP4XxifWQj1xqqxsk8tkxCNgkJGQZUz8R5zQytHL3Kkco5WAhDB89i9r38DBrt"
            local secret = "f393555dcc9657f22b3c309f8004b364e3f04de6db22d0a32ceff17637327099"
            local result = crypto.hdkey_secret_from_xprv(ctx, xprv)

            assert.equals(secret, result.secret)
        end)
    end)

    describe("a crypto.generate_random_bytes", function()
        it("should return a few random bytes", function()
            local result = crypto.generate_random_bytes(ctx, 8)

            assert.is_true(string.len(result.bytes or "") > 0)
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

    describe("a crypto.mnemonic_words", function()
        it("should return 'leopard' word among other", function()
            local result = crypto.mnemonic_words(ctx, 1)

            assert.truthy(string.find(result.words, "leopard"));
        end)
    end)

    describe("a crypto.verify_signature", function()
        it("should return unsigned message", function()
            local result = crypto.verify_signature(ctx, signed_message, tu.keys.public)

            assert(unsigned_message, result.unsigned)
        end)
    end)

    describe("a crypto.nacl_box_open", function()
        it("should return decrypted data", function()
            local nonce = "8618a02d351f0ce5f6bc0f56674e977a6a896a2cbb35d279" -- must be a 24-byte hex string
            local their_public = "b8e902c15096bf030fc8a0b3549bca15ca4bc74c3612964a72d93a2b00420308"
            local keys = {
                public = "9950d2f1a3cee9fcbc6614aba64636215c31edee31061de77c93d2fa62a67732",
                secret = "56fb22f277b9aee361f925b67bc97a31e302c20e4468b6c80fb1f840a12d6349"
            }
            local result = crypto.nacl_box_open(ctx, "GcIo9A7BWvjvmacO6iNDk5pPUFs6jY43T8mkzoKC", nonce, their_public, keys.secret)

            assert.equals("VE9OIFNESyB2MS4wLjA=", result.decrypted)
        end)
    end)

    describe("a crypto.nacl_secret_box", function()
        it("should return an encrypted data", function()
            local nonce = "8618a02d351f0ce5f6bc0f56674e977a6a896a2cbb35d279" -- must be a 24-byte hex string
            local keys = {
                public = "b8e902c15096bf030fc8a0b3549bca15ca4bc74c3612964a72d93a2b00420308",
                secret = "c9332e3f09c8de109122ea7ce992e579e475f7b1ae8d70a0e2bd911f8ffb0ec4"
            }
            local result = crypto.nacl_secret_box(ctx, "VE9OIFNESyB2MS4wLjA=", nonce, keys.secret)

            assert.equals("H0+O0nk3Tedp+Dd7Fp3kA8HH0f54TUyQdPb25PII", result.encrypted)
        end)
    end)

    describe("a crypto.sha256", function()
        it("should return sha256 sum", function()
            local result = crypto.sha256(ctx, "VE9OIFNESyB2MS4wLjA=")

            assert("5e57221322b9d97b82899341744189761563a2115f31d39d7293ffcf01ad17a8", result.hash)
        end)
    end)

    describe("a crypto.nacl_sign_open", function()
        it("should return unsigned message", function()
            local result = crypto.nacl_sign_open(ctx, signed_message, tu.keys.public)

            assert(unsigned_message, result.unsigned)
        end)
    end)

    describe("a crypto.nacl_box_keypair_from_secret_key", function()
        it("should return a key pair", function()
            local result = crypto.nacl_box_keypair_from_secret_key(ctx, tu.keys.secret)

            assert.equals(tu.keys.secret, result.secret)
        end)
    end)

    describe("a crypto.nacl_secret_box_open", function()
        it("should return a decrypted data", function()
            local nonce = "8618a02d351f0ce5f6bc0f56674e977a6a896a2cbb35d279" -- must be a 24-byte hex string
            local keys = {
                public = "b8e902c15096bf030fc8a0b3549bca15ca4bc74c3612964a72d93a2b00420308",
                secret = "c9332e3f09c8de109122ea7ce992e579e475f7b1ae8d70a0e2bd911f8ffb0ec4"
            }
            local result = crypto.nacl_secret_box_open(ctx, "H0+O0nk3Tedp+Dd7Fp3kA8HH0f54TUyQdPb25PII", nonce, keys.secret)

            assert.equals("VE9OIFNESyB2MS4wLjA=", result.decrypted)
        end)
    end)

    describe("a crypto.factorize", function()
        it("should return factors of a composite", function()
            local result = crypto.factorize(ctx, string.format("%016x", 12))

            assert.same({ "3", "4" }, result.factors)
        end)

        it("should error if a composite cannot be factorized", function()
            local _, err = pcall(crypto.factorize, ctx, string.format("%016x", 13))

            assert.equals(106, err.code)
        end)
    end)

    describe("a crypto.mnemonic_from_entropy", function()
        it("should return a mnemonic phrase", function()
            local phrase = "dawn fee flip salute width fancy prevent income early planet uphold boost travel concert explain"
            local result = crypto.mnemonic_from_entropy(ctx, "37ea91645f6faca5ea93944534bfbb0cde785d54", 1, 15)

            assert.equals(phrase, result.phrase)
        end)
    end)

    describe("a crypto.nacl_sign", function()
        it("should return a signed data", function()
            local unsigned_message = tu:create_encoded_message(
                ctx, { External = tu.keys.public }, 1599458364291, 1599458404)
            local secret =  tu.keys.secret .. tu.keys.public
            local result = crypto.nacl_sign(ctx, unsigned_message, secret)

            assert.equals(signed_message, result.signed)
        end)
    end)

    describe("a crypto.hdkey_xprv_from_mnemonic", function()
        it("should return xprv", function()
            local phrase = "dawn fee flip salute width fancy prevent income early planet uphold boost travel concert explain"
            local xprv = "xprv9s21ZrQH143K3PBHjRFACygw9K1AA8k2jTRkEDbuHX8MfTP4XxifWQj1xqqxsk8tkxCNgkJGQZUz8R5zQytHL3Kkco5WAhDB89i9r38DBrt"
            local result = crypto.hdkey_xprv_from_mnemonic(ctx, phrase)

            assert.equals(xprv, result.xprv)
        end)
    end)

    describe("a crypto.mnemonic_verify", function()
        it("should tell if a mnemonic phrase is valid", function()
            local phrase = "dawn fee flip salute width fancy prevent income early planet uphold boost travel concert explain"
            local result = crypto.mnemonic_verify(ctx, phrase, 1, 15)

            assert.is_true(result.valid)
        end)
    end)

    describe("a crypto.sign", function()
        it("should return a signed data", function()
            local unsigned_message = tu:create_encoded_message(
                ctx, { External = tu.keys.public }, 1599458364291, 1599458404)
            local result = crypto.sign(ctx, unsigned_message, tu.keys)

            assert.equals(signed_message, result.signed)
        end)
    end)

    describe("a crypto.convert_public_key_to_ton_safe_format", function()
        it("should convert a public key", function()
            local result = crypto.convert_public_key_to_ton_safe_format(ctx, tu.keys.public)

            assert.equals("PuYTTGeRCqC9RBDgtiN51RevE9-ZugR2S8oG4LqGxza4Cv_l", result.ton_public_key)
        end)
    end)

    describe("a crypto.ton_crc16", function()
        it("should return a CRC sum", function()
            local result = crypto.ton_crc16(ctx, "VE9OIFNESyB2MS4wLjA=")

            assert.equals(7158, result.crc)
        end)
    end)

    describe("a crypto.modular_power", function()
        it("should return a result of modular exponentiation", function()
            local result = crypto.modular_power(ctx, "05", "03", "0d")

            assert.equals("8", result.modular_power)
        end)
    end)

    describe("a crypto.sha512", function()
        it("should return sha512 sum", function()
            local result = crypto.sha512(ctx, "VE9OIFNESyB2MS4wLjA=")

            assert("ba0733ab208673e82f52805520e0ca48a6df1ebb75e2360ed02f73df1a069d991aa5006a6e585a75e08ad7e8c8616d281725b9e7a1b9801e3172ccbe20058721", result.hash)
        end)
    end)

    describe("a crypto.scrypt", function()
        it("should return a derived key", function()
            local result = crypto.scrypt(ctx, "cXVlcnR5", "c2FsdA==", 2, 8, 2, 8)

            assert("f507b99bc4e620cb", result.key)
        end)
    end)

    describe("a crypto.hdkey_derive_from_xprv", function()
        it("should return a derived xprv", function()
            local xprv = "xprv9s21ZrQH143K3PBHjRFACygw9K1AA8k2jTRkEDbuHX8MfTP4XxifWQj1xqqxsk8tkxCNgkJGQZUz8R5zQytHL3Kkco5WAhDB89i9r38DBrt"
            local derived_xprv = "xprv9umdhXwHgt9GyXA6NRKgaj9CeRPNgF6kZHnt49GQNTxoFuZ18CoLxHW22SkU7FoUfSa6eoirTVVtv7rkKeAobNPZ2FTQVbtdZ36qXdCqWfc"
            local result = crypto.hdkey_derive_from_xprv(ctx, xprv, 0x80000000, true)

            assert.equals(derived_xprv, result.xprv)
        end)
    end)

end)

