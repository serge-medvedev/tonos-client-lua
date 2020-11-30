local lib = require "tonos.client"
local abi = lib.abi
local boc = lib.boc
local net = lib.net
local processing = lib.processing
local json = require "dkjson"
local inspect = require "inspect"
local test_data = require "test_data"

local function prequire(m)
    local ok, x = pcall(require, m)

    if ok then
        return x
    else
        return nil
    end
end

local funding_wallet = prequire("funding_wallet")

local tt = {
    inspect = inspect,
    keys = {
        public = "134c67910aa0bd4410e0b62379d517af13df99ba04764bca06e0ba86c736b80a",
        secret = "ddf87be7c470ea26811e5ef86391cb97d79afb35098753c2f990c2b0aef5223d"
    },
    data = test_data
}

function tt.create_encoded_message(ctx, signer, time, expire)
    local pubkey = tt.keys.public

    if signer.type == "Keys" then
        pubkey = signer.keys.public
    elseif signer.type == "External" then
        pubkey = signer.public_key
    end

    local encode_message_params = {
        abi = { type = "Json", value = tt.data.events.abi },
        deploy_set = { tvc = tt.data.events.tvc },
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
    if funding_wallet == nil then
        error [[funding wallet config is missing - "paid" tests can't be run]]
    end

    local funded = false
    local process_message_params = {
        message_encode_params = {
            abi = { type = "Json", value = funding_wallet.abi },
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
        },
        send_events = false
    }

    for request_id, params_json, response_type, finished
        in processing.process_message(ctx, process_message_params) do

        local result = json.decode(params_json)

        if response_type == 1 then
            print(json.encode(process_message_params, { indent = true }))

            error(result)
        end

        if not result then result = {} end

        for _, out_message in pairs(result.out_messages or {}) do
            local m = boc.parse_message(ctx, { boc = out_message }).await().parsed

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

function tt.path(obj, ...)
    local value, path = obj, {...}

    for i, p in ipairs(path) do
        if (value[p] == nil) then
            return
        end

        value = value[p]
    end

    return value
end

function tt.clone(obj, shallow)
    if type(obj) ~= 'table' then return obj end
    local _obj = {}
    for i,v in pairs(obj) do
        if type(v) == 'table' then
            if not shallow then
                _obj[i] = clone(v,shallow)
            else _obj[i] = v
            end
        else
            _obj[i] = v
        end
    end
    return _obj
end

function tt.fromhex(s)
    return (s:gsub('..', function (cc)
        return string.char(tonumber(cc, 16))
    end))
end

function tt.tohex(s)
    return (s:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end

return tt

