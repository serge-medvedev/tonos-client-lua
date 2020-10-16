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
                    error(decoded, 2) -- blame caller
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

abi.decode_message = function(ctx, params_json)
    return async_iterator_factory(ctx, "abi.decode_message", params_json)
end

abi.attach_signature = function(ctx, params_json)
    return async_iterator_factory(ctx, "abi.attach_signature", params_json)
end

abi.encode_message = function(ctx, params_json)
    return async_iterator_factory(ctx, "abi.encode_message", params_json)
end

abi.encode_account = function(ctx, params_json)
    return async_iterator_factory(ctx, "abi.encode_account", params_json)
end

---------- Boc

local boc = {}

boc.parse_transaction = function(ctx, params_json)
    return async_iterator_factory(ctx, "boc.parse_transaction", params_json).pick("parsed")
end

boc.parse_block = function(ctx, params_json)
    return async_iterator_factory(ctx, "boc.parse_block", params_json).pick("parsed")
end

boc.parse_account = function(ctx, params_json)
    return async_iterator_factory(ctx, "boc.parse_account", params_json).pick("parsed")
end

boc.parse_message = function(ctx, params_json)
    return async_iterator_factory(ctx, "boc.parse_message", params_json).pick("parsed")
end

boc.get_blockchain_config = function(ctx, params_json)
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

crypto.hdkey_derive_from_xprv_path = function(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.hdkey_derive_from_xprv_path", params_json)
end

crypto.nacl_box = function(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.nacl_box", params_json)
end

crypto.hdkey_public_from_xprv = function(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.hdkey_public_from_xprv", params_json)
end

crypto.nacl_sign_detached = function(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.nacl_sign_detached", params_json)
end

crypto.mnemonic_from_random = function(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.mnemonic_from_random", params_json)
end

crypto.generate_random_sign_keys = function(ctx)
    return async_iterator_factory(ctx, "crypto.generate_random_sign_keys")
end

crypto.nacl_box_keypair = function(ctx)
    return async_iterator_factory(ctx, "crypto.nacl_box_keypair")
end

crypto.nacl_sign_keypair_from_secret_key = function(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.nacl_sign_keypair_from_secret_key", params_json)
end

crypto.hdkey_secret_from_xprv = function(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.hdkey_secret_from_xprv", params_json)
end

crypto.generate_random_bytes = function(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.generate_random_bytes", params_json)
end

crypto.mnemonic_words = function(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.mnemonic_words", params_json)
end

crypto.verify_signature = function(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.verify_signature", params_json)
end

crypto.nacl_box_open = function(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.nacl_box_open", params_json)
end

crypto.mnemonic_derive_sign_keys = function(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.mnemonic_derive_sign_keys", params_json)
end

crypto.nacl_secret_box = function(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.nacl_secret_box", params_json)
end

crypto.sha256 = function(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.sha256", params_json)
end

crypto.nacl_sign_open = function(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.nacl_sign_open", params_json)
end

crypto.nacl_box_keypair_from_secret_key = function(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.nacl_box_keypair_from_secret_key", params_json)
end

crypto.nacl_secret_box_open = function(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.nacl_secret_box_open", params_json)
end

crypto.factorize = function(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.factorize", params_json)
end

crypto.mnemonic_from_entropy = function(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.mnemonic_from_entropy", params_json)
end

crypto.nacl_sign = function(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.nacl_sign", params_json)
end

crypto.hdkey_xprv_from_mnemonic = function(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.hdkey_xprv_from_mnemonic", params_json)
end

crypto.mnemonic_verify = function(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.mnemonic_verify", params_json)
end

crypto.sign = function(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.sign", params_json)
end

crypto.convert_public_key_to_ton_safe_format = function(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.convert_public_key_to_ton_safe_format", params_json)
end

crypto.ton_crc16 = function(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.ton_crc16", params_json)
end

crypto.modular_power = function(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.modular_power", params_json)
end

crypto.sha512 = function(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.sha512", params_json)
end

crypto.scrypt = function(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.scrypt", params_json)
end

crypto.hdkey_derive_from_xprv = function(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.hdkey_derive_from_xprv", params_json)
end

---------- Net

local net = {}

net.query_collection = function(ctx, params_json)
    return async_iterator_factory(ctx, "net.query_collection", params_json).pick("result")
end

net.unsubscribe = function(ctx, params_json)
    return async_iterator_factory(ctx, "net.unsubscribe", params_json)
end

net.subscribe_collection = function(ctx, params_json)
    return async_iterator_factory(ctx, "net.subscribe_collection", params_json)
end

net.wait_for_collection = function(ctx, params_json)
    return async_iterator_factory(ctx, "net.wait_for_collection", params_json).pick("result")
end

---------- Processing

local processing = {}

processing.send_message = function(ctx, params_json)
    return async_iterator_factory(ctx, "processing.send_message", params_json)
end

processing.wait_for_transaction = function(ctx, params_json)
    return async_iterator_factory(ctx, "processing.wait_for_transaction", params_json)
end

processing.process_message = function(ctx, params_json)
    return async_iterator_factory(ctx, "processing.process_message", params_json)
end

---------- TVM

local tvm = {}

tvm.execute_message = function(ctx, params_json)
    return async_iterator_factory(ctx, "tvm.execute_message", params_json)
end

tvm.execute_get = function(ctx, params_json)
    return async_iterator_factory(ctx, "tvm.execute_get", params_json).pick("output")
end

---------- Utils

local utils = {}

utils.convert_address = function(ctx, params_json)
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

