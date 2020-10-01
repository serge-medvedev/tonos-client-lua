describe("an abi test suite", function()
    local context = require "context"
    local abi= require "abi"
    local crypto = require "crypto"
    local json = require "json"
    local inspect = require "inspect"

    local events_abi = '{"ABI version":2,"header":["pubkey","time","expire"],"functions":[{"name":"emitValue","inputs":[{"name":"id","type":"uint256"}],"outputs":[]},{"name":"returnValue","inputs":[{"name":"id","type":"uint256"}],"outputs":[{"name":"value0","type":"uint256"}]},{"name":"sendAllMoney","inputs":[{"name":"dest_addr","type":"address"}],"outputs":[]},{"name":"constructor","inputs":[],"outputs":[]}],"data":[],"events":[{"name":"EventThrown","inputs":[{"name":"id","type":"uint256"}],"outputs":[]}]}'
    local tvc = "te6ccgECFwEAAxUAAgE0BgEBAcACAgPPIAUDAQHeBAAD0CAAQdgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAIm/wD0pCAiwAGS9KDhiu1TWDD0oQkHAQr0pCD0oQgAAAIBIAwKAcj/fyHtRNAg10nCAY4Q0//TP9MA0X/4Yfhm+GP4Yo4Y9AVwAYBA9A7yvdcL//hicPhjcPhmf/hh4tMAAY4dgQIA1xgg+QEB0wABlNP/AwGTAvhC4iD4ZfkQ8qiV0wAB8nri0z8BCwBqjh74QyG5IJ8wIPgjgQPoqIIIG3dAoLnekvhj4IA08jTY0x8B+CO88rnTHwHwAfhHbpLyPN4CASASDQIBIA8OAL26i1Xz/4QW6ONe1E0CDXScIBjhDT/9M/0wDRf/hh+Gb4Y/hijhj0BXABgED0DvK91wv/+GJw+GNw+GZ/+GHi3vhG8nNx+GbR+AD4QsjL//hDzws/+EbPCwDJ7VR/+GeAIBIBEQAOW4gAa1vwgt0cJ9qJoaf/pn+mAaL/8MPwzfDH8MW99IMrqaOh9IG/o/CKQN0kYOG98IV15cDJ8AGRk/YIQZGfChGdGggQH0AAAAAAAAAAAAAAAAAAgZ4tkwIBAfYAYfCFkZf/8IeeFn/wjZ4WAZPaqP/wzwAMW5k8Ki3wgt0cJ9qJoaf/pn+mAaL/8MPwzfDH8MW9rhv/K6mjoaf/v6PwAZEXuAAAAAAAAAAAAAAAACGeLZ8DnyOPLGL0Q54X/5Lj9gBh8IWRl//wh54Wf/CNnhYBk9qo//DPACAUgWEwEJuLfFglAUAfz4QW6OE+1E0NP/0z/TANF/+GH4Zvhj+GLe1w3/ldTR0NP/39H4AMiL3AAAAAAAAAAAAAAAABDPFs+Bz5HHljF6Ic8L/8lx+wDIi9wAAAAAAAAAAAAAAAAQzxbPgc+SVviwSiHPC//JcfsAMPhCyMv/+EPPCz/4Rs8LAMntVH8VAAT4ZwBy3HAi0NYCMdIAMNwhxwCS8jvgIdcNH5LyPOFTEZLyO+HBBCKCEP////28sZLyPOAB8AH4R26S8jze"

    local ctx, keys

    setup(function()
        local config = '{"network": {"server_address": "https://net.ton.dev"}}'

        ctx = context.create(config).handle
        keys = {
            public = "134c67910aa0bd4410e0b62379d517af13df99ba04764bca06e0ba86c736b80a",
            secret = "ddf87be7c470ea26811e5ef86391cb97d79afb35098753c2f990c2b0aef5223d"
        }
    end)

    teardown(function()
        context.destroy(ctx)
    end)

    describe("an abi.decode_message", function()
        it("should return decoded data", function()
            local result = abi.decode_message(ctx, { Serialized = json.decode(events_abi) }, "te6ccgECGAEAA6wAA0eIAPk+BfTets8d5G5pBigDfDj+UVE1pHFHid5+nkoepWCSEbAHAgEA4ZVe85gsFXUX0aOVkSefmD97gDSdmOVkLsU9Bfbji22I7R+mhFUl7/BhhE6/xgekHUuxZ2MAOjifQ4dOP2MDLYFWhjaLrVuGrcuz3Pat6R9weM2EGopaBV3xA7ixvUdzlgAAAF04XRkpF91G+dotV8/gAQHAAwIDzyAGBAEB3gUAA9AgAEHa0MbRdatw1bl2e57VvSPuDxmwg1FLQKu+IHcWN6jucsQCJv8A9KQgIsABkvSg4YrtU1gw9KEKCAEK9KQg9KEJAAACASANCwHI/38h7UTQINdJwgGOENP/0z/TANF/+GH4Zvhj+GKOGPQFcAGAQPQO8r3XC//4YnD4Y3D4Zn/4YeLTAAGOHYECANcYIPkBAdMAAZTT/wMBkwL4QuIg+GX5EPKoldMAAfJ64tM/AQwAao4e+EMhuSCfMCD4I4ED6KiCCBt3QKC53pL4Y+CANPI02NMfAfgjvPK50x8B8AH4R26S8jzeAgEgEw4CASAQDwC9uotV8/+EFujjXtRNAg10nCAY4Q0//TP9MA0X/4Yfhm+GP4Yo4Y9AVwAYBA9A7yvdcL//hicPhjcPhmf/hh4t74RvJzcfhm0fgA+ELIy//4Q88LP/hGzwsAye1Uf/hngCASASEQDluIAGtb8ILdHCfaiaGn/6Z/pgGi//DD8M3wx/DFvfSDK6mjofSBv6PwikDdJGDhvfCFdeXAyfABkZP2CEGRnwoRnRoIEB9AAAAAAAAAAAAAAAAAAIGeLZMCAQH2AGHwhZGX//CHnhZ/8I2eFgGT2qj/8M8ADFuZPCot8ILdHCfaiaGn/6Z/pgGi//DD8M3wx/DFva4b/yupo6Gn/7+j8AGRF7gAAAAAAAAAAAAAAAAhni2fA58jjyxi9EOeF/+S4/YAYfCFkZf/8IeeFn/wjZ4WAZPaqP/wzwAgFIFxQBCbi3xYJQFQH8+EFujhPtRNDT/9M/0wDRf/hh+Gb4Y/hi3tcN/5XU0dDT/9/R+ADIi9wAAAAAAAAAAAAAAAAQzxbPgc+Rx5YxeiHPC//JcfsAyIvcAAAAAAAAAAAAAAAAEM8Wz4HPklb4sEohzwv/yXH7ADD4QsjL//hDzws/+EbPCwDJ7VR/FgAE+GcActxwItDWAjHSADDcIccAkvI74CHXDR+S8jzhUxGS8jvhwQQighD////9vLGS8jzgAfAB+EdukvI83g==")

            assert.equals("constructor", result.name)
        end)
    end)

    describe("an abi.attach_signature", function()
        local encoded = abi.encode_message(
            ctx,
            { Serialized = json.decode(events_abi) },
            nil,
            { tvc = tvc },
            { function_name = "constructor", header = { pubkey = keys.public, time = 1599458364291, expire = 1599458404 } },
            { External = keys.public })

        it("should return a signed message", function()
            local signature = crypto.nacl_sign_detached(ctx, encoded.message, keys.public .. keys.secret).signature
            local result = abi.attach_signature(
                ctx,
                { Serialized = json.decode(events_abi) },
                keys.public,
                encoded.message,
                signature)

            assert.equals("te6ccgECGAEAA6wAA0eIAGdkEejrY7lo2CR2+sfFyrbt7lCqqU8QkEW6xgcUNSFMEbAHAgEA4bhOLZvoOk79z/wDRxirygbaI7dU5FNMD3i+l55i79hdmc0Czrd45ZwlvyGFTP8fdK1v0rwLA9hoJuHc1LiDa4ZE0xnkQqgvUQQ4LYjedUXrxPfmboEdkvKBuC6hsc2uAoAAAF0ZyXLg19VzGRotV8/gAQHAAwIDzyAGBAEB3gUAA9AgAEHYmmM8iFUF6iCHBbEbzqi9eJ78zdAjsl5QNwXUNjm1wFQCJv8A9KQgIsABkvSg4YrtU1gw9KEKCAEK9KQg9KEJAAACASANCwHI/38h7UTQINdJwgGOENP/0z/TANF/+GH4Zvhj+GKOGPQFcAGAQPQO8r3XC//4YnD4Y3D4Zn/4YeLTAAGOHYECANcYIPkBAdMAAZTT/wMBkwL4QuIg+GX5EPKoldMAAfJ64tM/AQwAao4e+EMhuSCfMCD4I4ED6KiCCBt3QKC53pL4Y+CANPI02NMfAfgjvPK50x8B8AH4R26S8jzeAgEgEw4CASAQDwC9uotV8/+EFujjXtRNAg10nCAY4Q0//TP9MA0X/4Yfhm+GP4Yo4Y9AVwAYBA9A7yvdcL//hicPhjcPhmf/hh4t74RvJzcfhm0fgA+ELIy//4Q88LP/hGzwsAye1Uf/hngCASASEQDluIAGtb8ILdHCfaiaGn/6Z/pgGi//DD8M3wx/DFvfSDK6mjofSBv6PwikDdJGDhvfCFdeXAyfABkZP2CEGRnwoRnRoIEB9AAAAAAAAAAAAAAAAAAIGeLZMCAQH2AGHwhZGX//CHnhZ/8I2eFgGT2qj/8M8ADFuZPCot8ILdHCfaiaGn/6Z/pgGi//DD8M3wx/DFva4b/yupo6Gn/7+j8AGRF7gAAAAAAAAAAAAAAAAhni2fA58jjyxi9EOeF/+S4/YAYfCFkZf/8IeeFn/wjZ4WAZPaqP/wzwAgFIFxQBCbi3xYJQFQH8+EFujhPtRNDT/9M/0wDRf/hh+Gb4Y/hi3tcN/5XU0dDT/9/R+ADIi9wAAAAAAAAAAAAAAAAQzxbPgc+Rx5YxeiHPC//JcfsAyIvcAAAAAAAAAAAAAAAAEM8Wz4HPklb4sEohzwv/yXH7ADD4QsjL//hDzws/+EbPCwDJ7VR/FgAE+GcActxwItDWAjHSADDcIccAkvI74CHXDR+S8jzhUxGS8jvhwQQighD////9vLGS8jzgAfAB+EdukvI83g==", result.message)
        end)
    end)

    describe("an abi.encode_message", function()
        it("should return a BOC", function()
            local result = abi.encode_message(
                ctx,
                { Serialized = json.decode(events_abi) },
                nil,
                { tvc = tvc },
                { function_name = "constructor", header = { pubkey = keys.public } },
                { WithKeys = keys })

            assert.is_not_nil(result.address)
            assert.is_not_nil(result.message)
        end)
    end)
end)

