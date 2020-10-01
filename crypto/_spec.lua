describe("a crypto test suite", function()
	local context = require "context"
	local crypto = require "crypto"
	local inspect = require "inspect"

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
			local unsigned = "te6ccgECFwEAA2gAAqeIAfFpgwNvq9pmM7LQE3WndDqwdee72s8WGYuFhUBr6wCiEZMpW0HYNC2eO3MzzXuR3Ydu4uR84wNG53wOzNtmxDoMEAAAF04a3VFF91KptotV8/gGAQEBwAICA88gBQMBAd4EAAPQIABB2ZStoOwaFs8duZnmvcjuw7dxcj5xgaNzvgdmbbNiHQYMAib/APSkICLAAZL0oOGK7VNYMPShCQcBCvSkIPShCAAAAgEgDAoByP9/Ie1E0CDXScIBjhDT/9M/0wDRf/hh+Gb4Y/hijhj0BXABgED0DvK91wv/+GJw+GNw+GZ/+GHi0wABjh2BAgDXGCD5AQHTAAGU0/8DAZMC+ELiIPhl+RDyqJXTAAHyeuLTPwELAGqOHvhDIbkgnzAg+COBA+iogggbd0Cgud6S+GPggDTyNNjTHwH4I7zyudMfAfAB+EdukvI83gIBIBINAgEgDw4AvbqLVfP/hBbo417UTQINdJwgGOENP/0z/TANF/+GH4Zvhj+GKOGPQFcAGAQPQO8r3XC//4YnD4Y3D4Zn/4YeLe+Ebyc3H4ZtH4APhCyMv/+EPPCz/4Rs8LAMntVH/4Z4AgEgERAA5biABrW/CC3Rwn2omhp/+mf6YBov/ww/DN8Mfwxb30gyupo6H0gb+j8IpA3SRg4b3whXXlwMnwAZGT9ghBkZ8KEZ0aCBAfQAAAAAAAAAAAAAAAAACBni2TAgEB9gBh8IWRl//wh54Wf/CNnhYBk9qo//DPAAxbmTwqLfCC3Rwn2omhp/+mf6YBov/ww/DN8Mfwxb2uG/8rqaOhp/+/o/ABkRe4AAAAAAAAAAAAAAAAIZ4tnwOfI48sYvRDnhf/kuP2AGHwhZGX//CHnhZ/8I2eFgGT2qj/8M8AIBSBYTAQm4t8WCUBQB/PhBbo4T7UTQ0//TP9MA0X/4Yfhm+GP4Yt7XDf+V1NHQ0//f0fgAyIvcAAAAAAAAAAAAAAAAEM8Wz4HPkceWMXohzwv/yXH7AMiL3AAAAAAAAAAAAAAAABDPFs+Bz5JW+LBKIc8L/8lx+wAw+ELIy//4Q88LP/hGzwsAye1UfxUABPhnAHLccCLQ1gIx0gAw3CHHAJLyO+Ah1w0fkvI84VMRkvI74cEEIoIQ/////byxkvI84AHwAfhHbpLyPN4="
			local secret = "134c67910aa0bd4410e0b62379d517af13df99ba04764bca06e0ba86c736b80addf87be7c470ea26811e5ef86391cb97d79afb35098753c2f990c2b0aef5223d"
			local result = crypto.nacl_sign_detached(ctx, unsigned, secret)

			assert.equals(
				"423eae5f3f947e4e862927a33c778b8b616635d560682e2a4d4062af70183e51b639f2831e531b6312ffd35536400b3f387277198cb5429a15299e7188e22108",
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

