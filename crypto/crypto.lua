local tc = require "tonclua"
local json = require "json"

local crypto = {}

function crypto.hdkey_derive_from_xprv_path(ctx, ...)
end

function crypto.nacl_box(ctx, ...)
end

function crypto.hdkey_public_from_xprv(ctx, ...)
end

function crypto.nacl_sign_detached(ctx, ...)
end

function crypto.mnemonic_from_random(ctx, ...)
end

function crypto.generate_random_sign_keys(ctx, ...)
end

function crypto.nacl_box_keypair(ctx, ...)
end

function crypto.nacl_sign_keypair_from_secret(ctx, ...)
end

function crypto.hdkey_secret_from_xprv(ctx, ...)
end

function crypto.generate_random_bytes(ctx, ...)
end

function crypto.mnemonic_words(ctx, ...)
end

function crypto.verify_signature(ctx, ...)
end

function crypto.nacl_box_open(ctx, ...)
end

function crypto.mnemonic_derive_sign_keys(ctx, phrase, path, dictionary, word_count)
    local params_json = json.encode(
        { phrase = phrase, path = path, dictionary = dictionary, word_count = word_count })
    local response_handle = tc.json_request(ctx, "crypto.mnemonic_derive_sign_keys", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function crypto.nacl_secret_box(ctx, ...)
end

function crypto.sha256(ctx, ...)
end

function crypto.nacl_sign_open(ctx, ...)
end

function crypto.nacl_box_keypair_from_secret(ctx, ...)
end

function crypto.nacl_secret_box_open(ctx, ...)
end

function crypto.factorize(ctx, ...)
end

function crypto.mnemonic_from_entropy(ctx, ...)
end

function crypto.nacl_sign(ctx, ...)
end

function crypto.hdkey_xprv_from_mnemonic(ctx, ...)
end

function crypto.mnemonic_verify(ctx, ...)
end

function crypto.sign(ctx, ...)
end

function crypto.convert_public_key_to_ton_safe_format(ctx, ...)
end

function crypto.ton_crc16(ctx, ...)
end

function crypto.modular_power(ctx, ...)
end

function crypto.sha512(ctx, ...)
end

function crypto.scrypt(ctx, ...)
end

function crypto.hdkey_derive_from_xprv(ctx, ...)
end

return crypto

