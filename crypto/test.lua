package.path = "../?.lua;" .. package.path

local context = require "context"
local crypto = require "crypto"
local inspect = require "inspect"

local config = '{"network": {"server_address": "https://net.ton.dev"}}'
local ctx = context.create(config).handle

do  print("Testing crypto.mnemonic_derive_sign_keys")

    local result = crypto.mnemonic_derive_sign_keys(
        ctx, "dumb hunt swamp naive range drama snake network pride bag shoot earn", "m/44'/396'/0'/0/0")

    assert(result.public == "134c67910aa0bd4410e0b62379d517af13df99ba04764bca06e0ba86c736b80a")
    assert(result.secret == "ddf87be7c470ea26811e5ef86391cb97d79afb35098753c2f990c2b0aef5223d")
end

context.destroy(ctx)

