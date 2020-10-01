local tc = require "tonclua"
local json = require "json"

local crypto = {}

function crypto.hdkey_derive_from_xprv_path(ctx, xprv, path)
    local params_json = json.encode({ xprv = xprv, path = path })
    local response_handle = tc.json_request(ctx, "crypto.hdkey_derive_from_xprv_path", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function crypto.nacl_box(ctx, decrypted, nonce, their_public, secret)
    local params_json = json.encode(
        { decrypted = decrypted, nonce = nonce, their_public = their_public, secret = secret })
    local response_handle = tc.json_request(ctx, "crypto.nacl_box", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function crypto.hdkey_public_from_xprv(ctx, xprv)
    local params_json = json.encode({ xprv = xprv })
    local response_handle = tc.json_request(ctx, "crypto.hdkey_public_from_xprv", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function crypto.nacl_sign_detached(ctx, unsigned, secret)
    local params_json = json.encode({ unsigned = unsigned, secret = secret })
    local response_handle = tc.json_request(ctx, "crypto.nacl_sign_detached", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function crypto.mnemonic_from_random(ctx, dictionary, word_count)
    local params_json = json.encode({ dictionary = dictionary, word_count = word_count })
    local response_handle = tc.json_request(ctx, "crypto.mnemonic_from_random", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function crypto.generate_random_sign_keys(ctx)
    local response_handle = tc.json_request(ctx, "crypto.generate_random_sign_keys", "{}")
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function crypto.nacl_box_keypair(ctx)
    local response_handle = tc.json_request(ctx, "crypto.nacl_box_keypair", "{}")
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function crypto.nacl_sign_keypair_from_secret(ctx, secret)
    local params_json = json.encode({ secret = secret })
    local response_handle = tc.json_request(ctx, "crypto.nacl_sign_keypair_from_secret", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function crypto.hdkey_secret_from_xprv(ctx, xprv)
    local params_json = json.encode({ xprv = xprv })
    local response_handle = tc.json_request(ctx, "crypto.hdkey_secret_from_xprv", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function crypto.generate_random_bytes(ctx, length)
    local params_json = json.encode({ length = length })
    local response_handle = tc.json_request(ctx, "crypto.generate_random_bytes", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function crypto.mnemonic_words(ctx, dictionary)
    local params_json = json.encode({ dictionary = dictionary })
    local response_handle = tc.json_request(ctx, "crypto.mnemonic_words", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function crypto.verify_signature(ctx, signed, public)
    local params_json = json.encode({ signed = signed, public = public })
    local response_handle = tc.json_request(ctx, "crypto.verify_signature", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function crypto.nacl_box_open(ctx, encrypted, nonce, their_public, secret)
    local params_json = json.encode(
        { encrypted = encrypted, nonce = nonce, their_public = their_public, secret = secret })
    local response_handle = tc.json_request(ctx, "crypto.nacl_box_open", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
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

function crypto.nacl_secret_box(ctx, decrypted, nonce, key)
    local params_json = json.encode(
        { decrypted = decrypted, nonce = nonce, key = key })
    local response_handle = tc.json_request(ctx, "crypto.nacl_secret_box", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function crypto.sha256(ctx, data)
    local params_json = json.encode({ data = data })
    local response_handle = tc.json_request(ctx, "crypto.sha256", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function crypto.nacl_sign_open(ctx, signed, public)
    local params_json = json.encode({ signed = signed, public = public })
    local response_handle = tc.json_request(ctx, "crypto.nacl_sign_open", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function crypto.nacl_box_keypair_from_secret(ctx, secret)
    local params_json = json.encode({ secret = secret })
    local response_handle = tc.json_request(ctx, "crypto.nacl_box_keypair_from_secret", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function crypto.nacl_secret_box_open(ctx, encrypted, nonce, key)
    local params_json = json.encode(
        { encrypted = encrypted, nonce = nonce, key = key })
    local response_handle = tc.json_request(ctx, "crypto.nacl_secret_box_open", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function crypto.factorize(ctx, composite)
    local params_json = json.encode({ composite = composite })
    local response_handle = tc.json_request(ctx, "crypto.factorize", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function crypto.mnemonic_from_entropy(ctx, entropy, dictionary, word_count)
    local params_json = json.encode(
        { entropy = entropy, dictionary = dictionary, word_count = word_count })
    local response_handle = tc.json_request(ctx, "crypto.mnemonic_from_entropy", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function crypto.nacl_sign(ctx, unsigned, secret)
    local params_json = json.encode({ unsigned = unsigned, secret = secret })
    local response_handle = tc.json_request(ctx, "crypto.nacl_sign", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function crypto.hdkey_xprv_from_mnemonic(ctx, phrase)
    local params_json = json.encode({ phrase = phrase })
    local response_handle = tc.json_request(ctx, "crypto.hdkey_xprv_from_mnemonic", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function crypto.mnemonic_verify(ctx, phrase, dictionary, word_count)
    local params_json = json.encode(
        { phrase = phrase, dictionary = dictionary, word_count = word_count })
    local response_handle = tc.json_request(ctx, "crypto.mnemonic_verify", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function crypto.sign(ctx, unsigned, keys)
    local params_json = json.encode({ unsigned = unsigned, keys = keys })
    local response_handle = tc.json_request(ctx, "crypto.sign", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function crypto.convert_public_key_to_ton_safe_format(ctx, public_key)
    local params_json = json.encode({ public_key = public_key })
    local response_handle = tc.json_request(
        ctx, "crypto.convert_public_key_to_ton_safe_format", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function crypto.ton_crc16(ctx, data)
    local params_json = json.encode({ data = data })
    local response_handle = tc.json_request(ctx, "crypto.ton_crc16", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function crypto.modular_power(ctx, base, exponent, modulus)
    local params_json = json.encode({ base = base, exponent = exponent, modulus = modulus })
    local response_handle = tc.json_request(ctx, "crypto.modular_power", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function crypto.sha512(ctx, data)
    local params_json = json.encode({ data = data })
    local response_handle = tc.json_request(ctx, "crypto.sha512", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function crypto.scrypt(ctx, password, salt, log_n, r, p, dk_len)
    local params_json = json.encode(
        { password = password, salt = salt, log_n = log_n, r = r, p = p, dk_len = dk_len })
    local response_handle = tc.json_request(ctx, "crypto.scrypt", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

function crypto.hdkey_derive_from_xprv(ctx, xprv, child_index, hardened)
    local params_json = json.encode(
        { xprv = xprv, child_index = child_index, hardened = hardened })
    local response_handle = tc.json_request(ctx, "crypto.hdkey_derive_from_xprv", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

return crypto

