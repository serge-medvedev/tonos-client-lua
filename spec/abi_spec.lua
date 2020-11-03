describe("an abi test suite #abi", function()
    local lib = require "tonos.client"
    local context = lib.context
    local abi= lib.abi
    local crypto = lib.crypto
    local json = require "dkjson"
    local tt = require "spec.tools"

    local ctx

    setup(function()
        local config = '{"network": {"server_address": "https://net.ton.dev"}}'

        ctx = context.create(config)
    end)

    teardown(function()
        context.destroy(ctx)
    end)

    describe("an abi.decode_message", function()
        it("should return decoded data", function()
            local encoded = tt.create_encoded_message(ctx, { type = "Keys", keys = tt.keys })
            local result = abi.decode_message(ctx, {
                abi = { type = "Serialized", value = json.decode(tt.events.abi) },
                message = encoded.message
            }).await()

            assert.equals("constructor", result.name)
        end)
    end)

    describe("an abi.attach_signature", function()
        it("should return a signed message", function()
            local encoded = tt.create_encoded_message(
                ctx, { type = "External", public_key = tt.keys.public }, 1599458364291, 1599458404)
            local nacl_sign_detached_params = {
                unsigned = encoded.message,
                secret = tt.keys.secret .. tt.keys.public
            }
            local signature = crypto.nacl_sign_detached(ctx, nacl_sign_detached_params).await().signature
            local result = abi.attach_signature(ctx, {
                abi = { type = "Serialized", value = json.decode(tt.events.abi) },
                public_key = tt.keys.public,
                message = encoded.message,
                signature = signature
            }).await()

            assert.equals("te6ccgECGAEAA6wAA0eIAGdkEejrY7lo2CR2+sfFyrbt7lCqqU8QkEW6xgcUNSFMEbAHAgEA4f5wn3Xd1yv5w4IsitWh5eKl3dCyks6u6bomccs8mfmQXMXLcoyAd2MBOKPmsToGFICTw68Iq3mzFFEaLdFpUwJE0xnkQqgvUQQ4LYjedUXrxPfmboEdkvKBuC6hsc2uAoAAAF0ZyXLg19VzGRotV8/gAQHAAwIDzyAGBAEB3gUAA9AgAEHYmmM8iFUF6iCHBbEbzqi9eJ78zdAjsl5QNwXUNjm1wFQCJv8A9KQgIsABkvSg4YrtU1gw9KEKCAEK9KQg9KEJAAACASANCwHI/38h7UTQINdJwgGOENP/0z/TANF/+GH4Zvhj+GKOGPQFcAGAQPQO8r3XC//4YnD4Y3D4Zn/4YeLTAAGOHYECANcYIPkBAdMAAZTT/wMBkwL4QuIg+GX5EPKoldMAAfJ64tM/AQwAao4e+EMhuSCfMCD4I4ED6KiCCBt3QKC53pL4Y+CANPI02NMfAfgjvPK50x8B8AH4R26S8jzeAgEgEw4CASAQDwC9uotV8/+EFujjXtRNAg10nCAY4Q0//TP9MA0X/4Yfhm+GP4Yo4Y9AVwAYBA9A7yvdcL//hicPhjcPhmf/hh4t74RvJzcfhm0fgA+ELIy//4Q88LP/hGzwsAye1Uf/hngCASASEQDluIAGtb8ILdHCfaiaGn/6Z/pgGi//DD8M3wx/DFvfSDK6mjofSBv6PwikDdJGDhvfCFdeXAyfABkZP2CEGRnwoRnRoIEB9AAAAAAAAAAAAAAAAAAIGeLZMCAQH2AGHwhZGX//CHnhZ/8I2eFgGT2qj/8M8ADFuZPCot8ILdHCfaiaGn/6Z/pgGi//DD8M3wx/DFva4b/yupo6Gn/7+j8AGRF7gAAAAAAAAAAAAAAAAhni2fA58jjyxi9EOeF/+S4/YAYfCFkZf/8IeeFn/wjZ4WAZPaqP/wzwAgFIFxQBCbi3xYJQFQH8+EFujhPtRNDT/9M/0wDRf/hh+Gb4Y/hi3tcN/5XU0dDT/9/R+ADIi9wAAAAAAAAAAAAAAAAQzxbPgc+Rx5YxeiHPC//JcfsAyIvcAAAAAAAAAAAAAAAAEM8Wz4HPklb4sEohzwv/yXH7ADD4QsjL//hDzws/+EbPCwDJ7VR/FgAE+GcActxwItDWAjHSADDcIccAkvI74CHXDR+S8jzhUxGS8jvhwQQighD////9vLGS8jzgAfAB+EdukvI83g==", result.message)
        end)
    end)

    describe("an abi.encode_message", function()
        it("should return a BOC", function()
            local encode_message_params = {
                abi = { type = "Serialized", value = json.decode(tt.events.abi) },
                deploy_set = { tvc = tt.events.tvc },
                call_set = {
                    function_name = "constructor",
                    header = { pubkey = tt.keys.public }
                },
                signer = { type = "Keys", keys = tt.keys }
            }
            local result = abi.encode_message(ctx, encode_message_params).await()

            assert.is_not_nil(result.address)
            assert.is_not_nil(result.message)
        end)
    end)

    describe("an abi.encode_account", function()
        it("should return encoded account data", function()
            local elector_encoded = abi.encode_account(ctx, {
                state_init = { type = "StateInit", code = tt.elector.code, data = tt.elector.data }
            }).await()

            assert.equals("1089829edf8ad38e474ce9e93123b3281e52c3faff0214293cbb5981ee7b3092", elector_encoded.id)
        end)
    end)

    describe("an abi.encode_message_body", function()
        it("should return a BOC", function()
            local encode_message_body_params = {
                abi = { type = "Serialized", value = json.decode(tt.events.abi) },
                call_set = {
                    function_name = "returnValue",
                    header = {
                        expire = 1599458404,
                        time = 1599458364291,
                        pubkey = tt.keys.public
                    },
                    input = { id = 0 }
                },
                is_internal = false,
                signer = { type = "Keys", keys = tt.keys }
            }
            local result = abi.encode_message_body(ctx, encode_message_body_params).await()
            local expected = {
                body = "te6ccgEBAgEAlgAB4eb6eSBDZAg2YZ4IJ5P+cReLJ2jL1KmQPkzEKKsLLaZRiYUzUBzHX7IgJ0ZqQUGt44+ckKJ1BLDWadBa7O7OQALE0xnkQqgvUQQ4LYjedUXrxPfmboEdkvKBuC6hsc2uAoAAAF0ZyXLg19VzGQVviwSgAQBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
            }

            assert.same(expected, result)
        end)
    end)

    describe("an abi.attach_signature_to_message_body", function()
        it("should return a signed message body", function()
            local encode_message_body_params = {
                abi = { type = "Serialized", value = json.decode(tt.events.abi) },
                call_set = {
                    function_name = "returnValue",
                    header = {
                        expire = 1599458404,
                        time = 1599458364291,
                        pubkey = tt.keys.public
                    },
                    input = { id = 0 }
                },
                is_internal = false,
                signer = { type = "External", public_key = tt.keys.public }
            }
            local encoded_message_body = abi.encode_message_body(ctx, encode_message_body_params).await().body
            local nacl_sign_detached_params = {
                unsigned = encoded_message_body,
                secret = tt.keys.secret .. tt.keys.public
            }
            local signature = crypto.nacl_sign_detached(ctx, nacl_sign_detached_params).await().signature
            local result = abi.attach_signature_to_message_body(ctx, {
                abi = { type = "Serialized", value = json.decode(tt.events.abi) },
                public_key = tt.keys.public,
                message = encoded_message_body,
                signature = signature
            }).await()
            local expected = {
                body = "te6ccgEBAgEAlgAB4b8jS1IezemNgGrVnzkIxeOxxWRk2uithC4Ya6n6dSaFkqxwNokC5L6IXGGdNkE41utoA/yj1bSwm4amJtilh4PE0xnkQqgvUQQ4LYjedUXrxPfmboEdkvKBuC6hsc2uAoAAAF0ZyXLg19VzGQVviwSgAQBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
            }

            assert.same(expected, result)
        end)
    end)

    describe("an abi.decode_message_body", function()
        it("should return a message body decoded", function()
            local expected = {
                body_type = "Input",
                header = {
                    expire = 1599458404,
                    time = 1599458364291,
                    pubkey = "134c67910aa0bd4410e0b62379d517af13df99ba04764bca06e0ba86c736b80a"
                },
                name = "returnValue",
                value = { id = "0x0000000000000000000000000000000000000000000000000000000000000000" }
            }
            local decode_message_body_params = {
                abi = { type = "Serialized", value = json.decode(tt.events.abi) },
                body = "te6ccgEBAgEAlgAB4eb6eSBDZAg2YZ4IJ5P+cReLJ2jL1KmQPkzEKKsLLaZRiYUzUBzHX7IgJ0ZqQUGt44+ckKJ1BLDWadBa7O7OQALE0xnkQqgvUQQ4LYjedUXrxPfmboEdkvKBuC6hsc2uAoAAAF0ZyXLg19VzGQVviwSgAQBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
                is_internal = false
            }
            local result = abi.decode_message_body(ctx, decode_message_body_params).await()

            assert.same(expected, result)
        end)
    end)
end)

