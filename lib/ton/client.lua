local tc = require "tonclua"
local json = require "dkjson"

local function async_iterator_factory(ctx, method, params_json)
    local request_id = tc.request(ctx, method, json.encode(params_json) or "")
    local meta = {
        __call = coroutine.wrap(function()
            local id

            while request_id ~= id do
                id = tc.fetch_response_data(request_id) -- yields on the C-side, returns request_id when finished
            end
        end)
    }
    local iterator_factory = setmetatable({}, meta)
    local result_path = {}

    function iterator_factory.pick(...)
        result_path = { ... }

        return iterator_factory
    end

    function iterator_factory.await()
        for request_id, params_json, response_type, finished in iterator_factory do
            if finished then
                local decoded = json.decode(params_json)

                if response_type == 1 then
                    error(decoded, 2) -- blame the caller
                end

                for _, p in ipairs(result_path) do
                    if (decoded[p] == nil) then return end

                    decoded = decoded[p]
                end

                return decoded
            end
        end
    end

    return iterator_factory
end

---------- Abi

local abi = {}

function abi.decode_message(ctx, abi, message)
    local params_json = {
        abi = abi,
        message = message
    }

    return async_iterator_factory(ctx, "abi.decode_message", params_json)
end

function abi.attach_signature(ctx, abi, public_key, message, signature)
    local params_json = {
        abi = abi,
        public_key = public_key,
        message = message,
        signature = signature
    }

    return async_iterator_factory(ctx, "abi.attach_signature", params_json)
end

function abi.encode_message(ctx, abi, address, deploy_set, call_set, signer, processing_try_index)
    local params_json = {
        abi = abi,
        address = address,
        deploy_set = deploy_set,
        call_set = call_set,
        signer = signer,
        processing_try_index = processing_try_index
    }

    return async_iterator_factory(ctx, "abi.encode_message", params_json)
end

function abi.encode_account(ctx, state_init, balance, last_trans_lt, last_paid)
    local params_json = {
        state_init = state_init,
        balance = balance,
        last_trans_lt = last_trans_lt,
        last_paid = last_paid
    }

    return async_iterator_factory(ctx, "abi.encode_account", params_json)
end

---------- Boc

local boc = {}

function boc.parse_transaction(ctx, transaction)
    local params_json = { boc = transaction }

    return async_iterator_factory(ctx, "boc.parse_transaction", params_json).pick("parsed")
end

function boc.parse_block(ctx, block)
    local params_json = { boc = block }

    return async_iterator_factory(ctx, "boc.parse_block", params_json).pick("parsed")
end

function boc.parse_account(ctx, account)
    local params_json = { boc = account }

    return async_iterator_factory(ctx, "boc.parse_account", params_json).pick("parsed")
end

function boc.parse_message(ctx, message)
    local params_json = { boc = message }

    return async_iterator_factory(ctx, "boc.parse_message", params_json).pick("parsed")
end

function boc.get_blockchain_config(ctx, block_boc)
    local params_json = { block_boc = block_boc }

    return async_iterator_factory(ctx, "boc.get_blockchain_config", params_json).pick("parsed")
end

---------- Client

local client = {}

function client.version(ctx)
    return async_iterator_factory(ctx, "client.version")
end

function client.get_api_reference(ctx)
    return async_iterator_factory(ctx, "client.get_api_reference")
end

---------- Context

local context = {}

function context.create(config)
    local response_handle = tc.create_context(config)
    local result = tc.read_string(response_handle)
    local decoded = json.decode(result)

    if decoded == nil then
        error("empty response")
    elseif decoded.error then
        error(decoded.error)
    end

    return decoded.result
end

function context.destroy(handle)
    tc.destroy_context(handle)
end

---------- Crypto

local crypto = {}

function crypto.hdkey_derive_from_xprv_path(ctx, xprv, path)
    local params_json = {
        xprv = xprv,
        path = path
    }

    return async_iterator_factory(ctx, "crypto.hdkey_derive_from_xprv_path", params_json)
end

function crypto.nacl_box(ctx, decrypted, nonce, their_public, secret)
    local params_json = {
        decrypted = decrypted,
        nonce = nonce,
        their_public = their_public,
        secret = secret
    }

    return async_iterator_factory(ctx, "crypto.nacl_box", params_json)
end

function crypto.hdkey_public_from_xprv(ctx, xprv)
    local params_json = { xprv = xprv }

    return async_iterator_factory(ctx, "crypto.hdkey_public_from_xprv", params_json)
end

function crypto.nacl_sign_detached(ctx, unsigned, secret)
    local params_json = {
        unsigned = unsigned,
        secret = secret
    }

    return async_iterator_factory(ctx, "crypto.nacl_sign_detached", params_json)
end

function crypto.mnemonic_from_random(ctx, dictionary, word_count)
    local params_json = {
        dictionary = dictionary,
        word_count = word_count
    }

    return async_iterator_factory(ctx, "crypto.mnemonic_from_random", params_json)
end

function crypto.generate_random_sign_keys(ctx)
    return async_iterator_factory(ctx, "crypto.generate_random_sign_keys")
end

function crypto.nacl_box_keypair(ctx)
    return async_iterator_factory(ctx, "crypto.nacl_box_keypair")
end

function crypto.nacl_sign_keypair_from_secret_key(ctx, secret)
    local params_json = { secret = secret }

    return async_iterator_factory(ctx, "crypto.nacl_sign_keypair_from_secret_key", params_json)
end

function crypto.hdkey_secret_from_xprv(ctx, xprv)
    local params_json = { xprv = xprv }

    return async_iterator_factory(ctx, "crypto.hdkey_secret_from_xprv", params_json)
end

function crypto.generate_random_bytes(ctx, length)
    local params_json = { length = length }

    return async_iterator_factory(ctx, "crypto.generate_random_bytes", params_json)
end

function crypto.mnemonic_words(ctx, dictionary)
    local params_json = { dictionary = dictionary }

    return async_iterator_factory(ctx, "crypto.mnemonic_words", params_json)
end

function crypto.verify_signature(ctx, signed, public)
    local params_json = {
        signed = signed,
        public = public
    }

    return async_iterator_factory(ctx, "crypto.verify_signature", params_json)
end

function crypto.nacl_box_open(ctx, encrypted, nonce, their_public, secret)
    local params_json = {
        encrypted = encrypted,
        nonce = nonce,
        their_public = their_public,
        secret = secret
    }

    return async_iterator_factory(ctx, "crypto.nacl_box_open", params_json)
end

function crypto.mnemonic_derive_sign_keys(ctx, phrase, path, dictionary, word_count)
    local params_json = {
        phrase = phrase,
        path = path,
        dictionary = dictionary,
        word_count = word_count
    }

    return async_iterator_factory(ctx, "crypto.mnemonic_derive_sign_keys", params_json)
end

function crypto.nacl_secret_box(ctx, decrypted, nonce, key)
    local params_json = {
        decrypted = decrypted,
        nonce = nonce,
        key = key
    }

    return async_iterator_factory(ctx, "crypto.nacl_secret_box", params_json)
end

function crypto.sha256(ctx, data)
    local params_json = { data = data }

    return async_iterator_factory(ctx, "crypto.sha256", params_json)
end

function crypto.nacl_sign_open(ctx, signed, public)
    local params_json = {
        signed = signed,
        public = public
    }

    return async_iterator_factory(ctx, "crypto.nacl_sign_open", params_json)
end

function crypto.nacl_box_keypair_from_secret_key(ctx, secret)
    local params_json = { secret = secret }

    return async_iterator_factory(ctx, "crypto.nacl_box_keypair_from_secret_key", params_json)
end

function crypto.nacl_secret_box_open(ctx, encrypted, nonce, key)
    local params_json = {
        encrypted = encrypted,
        nonce = nonce,
        key = key
    }

    return async_iterator_factory(ctx, "crypto.nacl_secret_box_open", params_json)
end

function crypto.factorize(ctx, composite)
    local params_json = { composite = composite }

    return async_iterator_factory(ctx, "crypto.factorize", params_json)
end

function crypto.mnemonic_from_entropy(ctx, entropy, dictionary, word_count)
    local params_json = {
        entropy = entropy,
        dictionary = dictionary,
        word_count = word_count
    }

    return async_iterator_factory(ctx, "crypto.mnemonic_from_entropy", params_json)
end

function crypto.nacl_sign(ctx, unsigned, secret)
    local params_json = {
        unsigned = unsigned,
        secret = secret
    }

    return async_iterator_factory(ctx, "crypto.nacl_sign", params_json)
end

function crypto.hdkey_xprv_from_mnemonic(ctx, phrase)
    local params_json = { phrase = phrase }

    return async_iterator_factory(ctx, "crypto.hdkey_xprv_from_mnemonic", params_json)
end

function crypto.mnemonic_verify(ctx, phrase, dictionary, word_count)
    local params_json = {
        phrase = phrase,
        dictionary = dictionary,
        word_count = word_count
    }

    return async_iterator_factory(ctx, "crypto.mnemonic_verify", params_json)
end

function crypto.sign(ctx, unsigned, keys)
    local params_json = {
        unsigned = unsigned,
        keys = keys
    }

    return async_iterator_factory(ctx, "crypto.sign", params_json)
end

function crypto.convert_public_key_to_ton_safe_format(ctx, public_key)
    local params_json = { public_key = public_key }

    return async_iterator_factory(ctx, "crypto.convert_public_key_to_ton_safe_format", params_json)
end

function crypto.ton_crc16(ctx, data)
    local params_json = { data = data }

    return async_iterator_factory(ctx, "crypto.ton_crc16", params_json)
end

function crypto.modular_power(ctx, base, exponent, modulus)
    local params_json = {
        base = base,
        exponent = exponent,
        modulus = modulus
    }

    return async_iterator_factory(ctx, "crypto.modular_power", params_json)
end

function crypto.sha512(ctx, data)
    local params_json = { data = data }

    return async_iterator_factory(ctx, "crypto.sha512", params_json)
end

function crypto.scrypt(ctx, password, salt, log_n, r, p, dk_len)
    local params_json = {
        password = password,
        salt = salt,
        log_n = log_n,
        r = r,
        p = p,
        dk_len = dk_len
    }

    return async_iterator_factory(ctx, "crypto.scrypt", params_json)
end

function crypto.hdkey_derive_from_xprv(ctx, xprv, child_index, hardened)
    local params_json = {
        xprv = xprv,
        child_index = child_index,
        hardened = hardened
    }

    return async_iterator_factory(ctx, "crypto.hdkey_derive_from_xprv", params_json)
end

---------- Net

local net = {}

--! @param collection might be "accounts", "blocks", "transactions", "messages" or "block_signatures"
function net.query_collection(ctx, collection, filter, result, order, limit)
    local params_json = {
        collection = collection,
        filter = filter,
        result = result,
        order = order,
        limit = limit
    }

    return async_iterator_factory(ctx, "net.query_collection", params_json).pick("result")
end

function net.unsubscribe(ctx, handle)
    local params_json = { handle = handle }

    return async_iterator_factory(ctx, "net.unsubscribe", params_json)
end

--! Subscribes you to the stream of collection-dependent events.
--! The first successful response contains the subscription handle.
--! Don't forget to unsubscribe to prevent the buffering of unnecessary events.
--! @param collection might be "accounts", "blocks", "transactions", "messages" or "block_signatures"
--! @return iterator factory which can be traversed via generic for loop
function net.subscribe_collection(ctx, collection, filter, result)
    local params_json = {
        collection = collection,
        filter = filter,
        result = result
    }

    return async_iterator_factory(ctx, "net.subscribe_collection", params_json)
end

--! @param collection might be "accounts", "blocks", "transactions", "messages" or "block_signatures"
function net.wait_for_collection(ctx, collection, filter, result, timeout)
    local params_json = {
        collection = collection,
        filter = filter,
        result = result,
        timeout = timeout
    }

    return async_iterator_factory(ctx, "net.wait_for_collection", params_json).pick("result")
end

---------- Processing

local processing = {}

function processing.send_message(ctx, message, abi, send_events)
    local params_json = {
        message = message,
        abi = abi,
        send_events = send_events
    }

    return async_iterator_factory(ctx, "processing.send_message", params_json)
end

function processing.wait_for_transaction(ctx, message, abi, shard_block_id, send_events)
    local params_json = {
        abi = abi,
        message = message,
        shard_block_id = shard_block_id,
        send_events = send_events
    }

    return async_iterator_factory(ctx, "processing.wait_for_transaction", params_json)
end

function processing.process_message(ctx, message, abi, send_events)
    local params_json = {
        message = { Encoded = { message = message, abi = abi } },
        send_events = send_events
    }

    return async_iterator_factory(ctx, "processing.process_message", params_json)
end

---------- TVM

local tvm = {}

function tvm.execute_message(ctx, message, account, mode, execution_options)
    local params_json = {
        message = message,
        account = account,
        mode = mode,
        execution_options = execution_options
    }

    return async_iterator_factory(ctx, "tvm.execute_message", params_json)
end

function tvm.execute_get(ctx, account, function_name, input, execution_options)
    local params_json = {
        account = account,
        function_name = function_name,
        input = input,
        execution_options = execution_options
    }

    return async_iterator_factory(ctx, "tvm.execute_get", params_json).pick("output")
end

---------- Utils

local utils = {}

function utils.convert_address(ctx, address, output_format)
    local params_json = {
        address = address,
        output_format = output_format
    }

    return async_iterator_factory(ctx, "utils.convert_address", params_json)
end

return {
    abi = abi,
    boc = boc,
    client = client,
    context = context,
    crypto = crypto,
    net = net,
    processing = processing,
    tvm = tvm,
    utils = utils
}

