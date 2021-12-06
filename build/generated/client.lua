local tc = require "tonosclua"
local json = require "dkjson"

local function async_iterator_factory(ctx, method, params_json)
    local request_id = tc.request(ctx, method, json.encode(params_json) or "")
    local meta = {
        __call = coroutine.wrap(function()
            local id

            while request_id ~= id do
                id = tc.fetch_response_data(ctx, request_id) -- yields on the C-side, returns request_id when finished
            end
        end)
    }
    local iterator_factory = setmetatable({}, meta)

    function iterator_factory.await()
        for request_id, params_json, response_type, finished in iterator_factory do
            if finished then
                return json.decode(params_json)
            end
        end
    end

    return iterator_factory
end

---------- context: methods for context creation/destroying

local context = {}

function context.create(config)
    return tc.create_context(config)
end

function context.destroy(handle)
    tc.destroy_context(handle)
end

---------- client:Provides information about library.

local client = {}

function client.get_api_reference(ctx, params_json)
    return async_iterator_factory(ctx, "client.get_api_reference", params_json)
end

function client.version(ctx, params_json)
    return async_iterator_factory(ctx, "client.version", params_json)
end

function client.build_info(ctx, params_json)
    return async_iterator_factory(ctx, "client.build_info", params_json)
end

function client.resolve_app_request(ctx, params_json)
    return async_iterator_factory(ctx, "client.resolve_app_request", params_json)
end

---------- crypto:Crypto functions.

local crypto = {}

function crypto.factorize(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.factorize", params_json)
end

function crypto.modular_power(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.modular_power", params_json)
end

function crypto.ton_crc16(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.ton_crc16", params_json)
end

function crypto.generate_random_bytes(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.generate_random_bytes", params_json)
end

function crypto.convert_public_key_to_ton_safe_format(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.convert_public_key_to_ton_safe_format", params_json)
end

function crypto.generate_random_sign_keys(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.generate_random_sign_keys", params_json)
end

function crypto.sign(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.sign", params_json)
end

function crypto.verify_signature(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.verify_signature", params_json)
end

function crypto.sha256(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.sha256", params_json)
end

function crypto.sha512(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.sha512", params_json)
end

function crypto.scrypt(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.scrypt", params_json)
end

function crypto.nacl_sign_keypair_from_secret_key(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.nacl_sign_keypair_from_secret_key", params_json)
end

function crypto.nacl_sign(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.nacl_sign", params_json)
end

function crypto.nacl_sign_open(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.nacl_sign_open", params_json)
end

function crypto.nacl_sign_detached(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.nacl_sign_detached", params_json)
end

function crypto.nacl_sign_detached_verify(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.nacl_sign_detached_verify", params_json)
end

function crypto.nacl_box_keypair(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.nacl_box_keypair", params_json)
end

function crypto.nacl_box_keypair_from_secret_key(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.nacl_box_keypair_from_secret_key", params_json)
end

function crypto.nacl_box(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.nacl_box", params_json)
end

function crypto.nacl_box_open(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.nacl_box_open", params_json)
end

function crypto.nacl_secret_box(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.nacl_secret_box", params_json)
end

function crypto.nacl_secret_box_open(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.nacl_secret_box_open", params_json)
end

function crypto.mnemonic_words(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.mnemonic_words", params_json)
end

function crypto.mnemonic_from_random(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.mnemonic_from_random", params_json)
end

function crypto.mnemonic_from_entropy(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.mnemonic_from_entropy", params_json)
end

function crypto.mnemonic_verify(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.mnemonic_verify", params_json)
end

function crypto.mnemonic_derive_sign_keys(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.mnemonic_derive_sign_keys", params_json)
end

function crypto.hdkey_xprv_from_mnemonic(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.hdkey_xprv_from_mnemonic", params_json)
end

function crypto.hdkey_derive_from_xprv(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.hdkey_derive_from_xprv", params_json)
end

function crypto.hdkey_derive_from_xprv_path(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.hdkey_derive_from_xprv_path", params_json)
end

function crypto.hdkey_secret_from_xprv(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.hdkey_secret_from_xprv", params_json)
end

function crypto.hdkey_public_from_xprv(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.hdkey_public_from_xprv", params_json)
end

function crypto.chacha20(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.chacha20", params_json)
end

function crypto.register_signing_box(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.register_signing_box", params_json)
end

function crypto.get_signing_box(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.get_signing_box", params_json)
end

function crypto.signing_box_get_public_key(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.signing_box_get_public_key", params_json)
end

function crypto.signing_box_sign(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.signing_box_sign", params_json)
end

function crypto.remove_signing_box(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.remove_signing_box", params_json)
end

function crypto.register_encryption_box(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.register_encryption_box", params_json)
end

function crypto.remove_encryption_box(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.remove_encryption_box", params_json)
end

function crypto.encryption_box_get_info(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.encryption_box_get_info", params_json)
end

function crypto.encryption_box_encrypt(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.encryption_box_encrypt", params_json)
end

function crypto.encryption_box_decrypt(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.encryption_box_decrypt", params_json)
end

function crypto.create_encryption_box(ctx, params_json)
    return async_iterator_factory(ctx, "crypto.create_encryption_box", params_json)
end

---------- abi:Provides message encoding and decoding according to the ABI specification.

local abi = {}

function abi.encode_message_body(ctx, params_json)
    return async_iterator_factory(ctx, "abi.encode_message_body", params_json)
end

function abi.attach_signature_to_message_body(ctx, params_json)
    return async_iterator_factory(ctx, "abi.attach_signature_to_message_body", params_json)
end

function abi.encode_message(ctx, params_json)
    return async_iterator_factory(ctx, "abi.encode_message", params_json)
end

function abi.encode_internal_message(ctx, params_json)
    return async_iterator_factory(ctx, "abi.encode_internal_message", params_json)
end

function abi.attach_signature(ctx, params_json)
    return async_iterator_factory(ctx, "abi.attach_signature", params_json)
end

function abi.decode_message(ctx, params_json)
    return async_iterator_factory(ctx, "abi.decode_message", params_json)
end

function abi.decode_message_body(ctx, params_json)
    return async_iterator_factory(ctx, "abi.decode_message_body", params_json)
end

function abi.encode_account(ctx, params_json)
    return async_iterator_factory(ctx, "abi.encode_account", params_json)
end

function abi.decode_account_data(ctx, params_json)
    return async_iterator_factory(ctx, "abi.decode_account_data", params_json)
end

function abi.update_initial_data(ctx, params_json)
    return async_iterator_factory(ctx, "abi.update_initial_data", params_json)
end

function abi.encode_initial_data(ctx, params_json)
    return async_iterator_factory(ctx, "abi.encode_initial_data", params_json)
end

function abi.decode_initial_data(ctx, params_json)
    return async_iterator_factory(ctx, "abi.decode_initial_data", params_json)
end

function abi.decode_boc(ctx, params_json)
    return async_iterator_factory(ctx, "abi.decode_boc", params_json)
end

---------- boc:BOC manipulation module.

local boc = {}

function boc.parse_message(ctx, params_json)
    return async_iterator_factory(ctx, "boc.parse_message", params_json)
end

function boc.parse_transaction(ctx, params_json)
    return async_iterator_factory(ctx, "boc.parse_transaction", params_json)
end

function boc.parse_account(ctx, params_json)
    return async_iterator_factory(ctx, "boc.parse_account", params_json)
end

function boc.parse_block(ctx, params_json)
    return async_iterator_factory(ctx, "boc.parse_block", params_json)
end

function boc.parse_shardstate(ctx, params_json)
    return async_iterator_factory(ctx, "boc.parse_shardstate", params_json)
end

function boc.get_blockchain_config(ctx, params_json)
    return async_iterator_factory(ctx, "boc.get_blockchain_config", params_json)
end

function boc.get_boc_hash(ctx, params_json)
    return async_iterator_factory(ctx, "boc.get_boc_hash", params_json)
end

function boc.get_boc_depth(ctx, params_json)
    return async_iterator_factory(ctx, "boc.get_boc_depth", params_json)
end

function boc.get_code_from_tvc(ctx, params_json)
    return async_iterator_factory(ctx, "boc.get_code_from_tvc", params_json)
end

function boc.cache_get(ctx, params_json)
    return async_iterator_factory(ctx, "boc.cache_get", params_json)
end

function boc.cache_set(ctx, params_json)
    return async_iterator_factory(ctx, "boc.cache_set", params_json)
end

function boc.cache_unpin(ctx, params_json)
    return async_iterator_factory(ctx, "boc.cache_unpin", params_json)
end

function boc.encode_boc(ctx, params_json)
    return async_iterator_factory(ctx, "boc.encode_boc", params_json)
end

function boc.get_code_salt(ctx, params_json)
    return async_iterator_factory(ctx, "boc.get_code_salt", params_json)
end

function boc.set_code_salt(ctx, params_json)
    return async_iterator_factory(ctx, "boc.set_code_salt", params_json)
end

function boc.decode_tvc(ctx, params_json)
    return async_iterator_factory(ctx, "boc.decode_tvc", params_json)
end

function boc.encode_tvc(ctx, params_json)
    return async_iterator_factory(ctx, "boc.encode_tvc", params_json)
end

function boc.get_compiler_version(ctx, params_json)
    return async_iterator_factory(ctx, "boc.get_compiler_version", params_json)
end

---------- processing:Message processing module.

local processing = {}

function processing.send_message(ctx, params_json)
    return async_iterator_factory(ctx, "processing.send_message", params_json)
end

function processing.wait_for_transaction(ctx, params_json)
    return async_iterator_factory(ctx, "processing.wait_for_transaction", params_json)
end

function processing.process_message(ctx, params_json)
    return async_iterator_factory(ctx, "processing.process_message", params_json)
end

---------- utils:Misc utility Functions.

local utils = {}

function utils.convert_address(ctx, params_json)
    return async_iterator_factory(ctx, "utils.convert_address", params_json)
end

function utils.get_address_type(ctx, params_json)
    return async_iterator_factory(ctx, "utils.get_address_type", params_json)
end

function utils.calc_storage_fee(ctx, params_json)
    return async_iterator_factory(ctx, "utils.calc_storage_fee", params_json)
end

function utils.compress_zstd(ctx, params_json)
    return async_iterator_factory(ctx, "utils.compress_zstd", params_json)
end

function utils.decompress_zstd(ctx, params_json)
    return async_iterator_factory(ctx, "utils.decompress_zstd", params_json)
end

---------- tvm:

local tvm = {}

function tvm.run_executor(ctx, params_json)
    return async_iterator_factory(ctx, "tvm.run_executor", params_json)
end

function tvm.run_tvm(ctx, params_json)
    return async_iterator_factory(ctx, "tvm.run_tvm", params_json)
end

function tvm.run_get(ctx, params_json)
    return async_iterator_factory(ctx, "tvm.run_get", params_json)
end

---------- net:Network access.

local net = {}

function net.query(ctx, params_json)
    return async_iterator_factory(ctx, "net.query", params_json)
end

function net.batch_query(ctx, params_json)
    return async_iterator_factory(ctx, "net.batch_query", params_json)
end

function net.query_collection(ctx, params_json)
    return async_iterator_factory(ctx, "net.query_collection", params_json)
end

function net.aggregate_collection(ctx, params_json)
    return async_iterator_factory(ctx, "net.aggregate_collection", params_json)
end

function net.wait_for_collection(ctx, params_json)
    return async_iterator_factory(ctx, "net.wait_for_collection", params_json)
end

function net.unsubscribe(ctx, params_json)
    return async_iterator_factory(ctx, "net.unsubscribe", params_json)
end

function net.subscribe_collection(ctx, params_json)
    return async_iterator_factory(ctx, "net.subscribe_collection", params_json)
end

function net.suspend(ctx, params_json)
    return async_iterator_factory(ctx, "net.suspend", params_json)
end

function net.resume(ctx, params_json)
    return async_iterator_factory(ctx, "net.resume", params_json)
end

function net.find_last_shard_block(ctx, params_json)
    return async_iterator_factory(ctx, "net.find_last_shard_block", params_json)
end

function net.fetch_endpoints(ctx, params_json)
    return async_iterator_factory(ctx, "net.fetch_endpoints", params_json)
end

function net.set_endpoints(ctx, params_json)
    return async_iterator_factory(ctx, "net.set_endpoints", params_json)
end

function net.get_endpoints(ctx, params_json)
    return async_iterator_factory(ctx, "net.get_endpoints", params_json)
end

function net.query_counterparties(ctx, params_json)
    return async_iterator_factory(ctx, "net.query_counterparties", params_json)
end

function net.query_transaction_tree(ctx, params_json)
    return async_iterator_factory(ctx, "net.query_transaction_tree", params_json)
end

function net.create_block_iterator(ctx, params_json)
    return async_iterator_factory(ctx, "net.create_block_iterator", params_json)
end

function net.resume_block_iterator(ctx, params_json)
    return async_iterator_factory(ctx, "net.resume_block_iterator", params_json)
end

function net.create_transaction_iterator(ctx, params_json)
    return async_iterator_factory(ctx, "net.create_transaction_iterator", params_json)
end

function net.resume_transaction_iterator(ctx, params_json)
    return async_iterator_factory(ctx, "net.resume_transaction_iterator", params_json)
end

function net.iterator_next(ctx, params_json)
    return async_iterator_factory(ctx, "net.iterator_next", params_json)
end

function net.remove_iterator(ctx, params_json)
    return async_iterator_factory(ctx, "net.remove_iterator", params_json)
end

---------- debot:[UNSTABLE](UNSTABLE.md) Module for working with debot.

local debot = {}

function debot.init(ctx, params_json)
    return async_iterator_factory(ctx, "debot.init", params_json)
end

function debot.start(ctx, params_json)
    return async_iterator_factory(ctx, "debot.start", params_json)
end

function debot.fetch(ctx, params_json)
    return async_iterator_factory(ctx, "debot.fetch", params_json)
end

function debot.execute(ctx, params_json)
    return async_iterator_factory(ctx, "debot.execute", params_json)
end

function debot.send(ctx, params_json)
    return async_iterator_factory(ctx, "debot.send", params_json)
end

function debot.remove(ctx, params_json)
    return async_iterator_factory(ctx, "debot.remove", params_json)
end

---------- proofs:[UNSTABLE](UNSTABLE.md) Module for proving data, retrieved from TONOS API.

local proofs = {}

function proofs.proof_block_data(ctx, params_json)
    return async_iterator_factory(ctx, "proofs.proof_block_data", params_json)
end

function proofs.proof_transaction_data(ctx, params_json)
    return async_iterator_factory(ctx, "proofs.proof_transaction_data", params_json)
end

function proofs.proof_message_data(ctx, params_json)
    return async_iterator_factory(ctx, "proofs.proof_message_data", params_json)
end

return {
    context = context,
    client = client,
    crypto = crypto,
    abi = abi,
    boc = boc,
    processing = processing,
    utils = utils,
    tvm = tvm,
    net = net,
    debot = debot,
    proofs = proofs
}

