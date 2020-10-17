local lib = require "ton.client"
local abi = lib.abi
local net = lib.net
local processing = lib.processing
local json = require "dkjson"
local inspect = require "inspect"
local elector = require "elector"
local events = require "events"
local subscription = require "subscription"
local _, funding_wallet = pcall(require, "funding_wallet")

local tt = {
    inspect = inspect,
    elector = elector,
    events = events,
    subscription = subscription,
    keys = {
        public = "134c67910aa0bd4410e0b62379d517af13df99ba04764bca06e0ba86c736b80a",
        secret = "ddf87be7c470ea26811e5ef86391cb97d79afb35098753c2f990c2b0aef5223d"
    }
}

function tt.create_encoded_message(ctx, signer, time, expire)
    local pubkey = tt.keys.public

    if signer.type == "Keys" then
        pubkey = signer.keys.public
    elseif signer.type == "External" then
        pubkey = signer.public_key
    end

    local encode_message_params = {
        abi = { type = "Serialized", value = json.decode(tt.events.abi) },
        deploy_set = { tvc = tt.events.tvc },
        call_set = {
            function_name = "constructor",
            header = {
                pubkey = pubkey,
                time = time,
                expire = expire
            }
        },
        signer = signer
    }

    return abi.encode_message(ctx, encode_message_params).await()
end

function tt.fund_account(ctx, account, value)
    local encode_message_params = {
        abi = { type = "Serialized", value = json.decode(funding_wallet.abi) },
        address = funding_wallet.address,
        call_set = {
            function_name = "sendTransaction",
            input = {
                dest = account,
                value = value or 5e8,
                bounce = false,
                flags = 0,
                payload = ""
            }
        },
        signer = { type = "Keys", keys = funding_wallet.keys }
    }
    local encoded = abi.encode_message(ctx, encode_message_params).await()
    local funded = false
    local process_message_params = {
        message = { Encoded = { message = encoded.message, abi = Abi } },
        send_events = false
    }

    for request_id, params_json, response_type, finished
        in processing.process_message(ctx, process_message_params) do

        local result = json.decode(params_json)

        if not result then result = {} end

        for _, m in pairs(result.out_messages or {}) do
            if m.msg_type_name == "internal" then
                local wait_for_collection_params = {
                    collection = "transactions",
                    filter = { in_msg = { eq = m.id } },
                    result = "id",
                    timeout = 60000
                }
                local data = net.wait_for_collection(ctx, wait_for_collection_params).await().result

                funded = data.id ~= nil
            end
        end
    end

    if not funded then
        error("failed to fund the account")
    end
end

function tt.fetch_account(ctx, account)
    local wait_for_collection_params = {
        collection = "accounts",
        filter = { id = { eq = account } },
        result = "id boc",
        timeout = 60000
    }
    local result = net.wait_for_collection(ctx, wait_for_collection_params).await().result

    return result
end

return tt

