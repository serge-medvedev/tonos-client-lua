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

function tt:create_encoded_message(ctx, signer, time, expire)
    local pubkey = self.keys.public

    if signer.WithKeys then
        pubkey = signer.WithKeys.public
    elseif signer.External then
        pubkey = signer.External
    end

    return abi.encode_message(
        ctx,
        { Serialized = json.decode(tt.events.abi) },
        nil,
        { tvc = tt.events.tvc },
        { function_name = "constructor",
          header = { pubkey = pubkey, time = time, expire = expire } },
        signer)
end

function tt.print_callback_args(request_id, params_json, response_type, finished)
    print(inspect({
        request_id = request_id,
        params_json = params_json,
        response_type = response_type,
        finished = finished
    }))
end

function tt.fund_account(ctx, account, value)
    local Abi = { Serialized = json.decode(funding_wallet.abi) }
    local address = funding_wallet.address
    local deploy_set = nil
    local call_set = {
        function_name = "sendTransaction",
        input = {
            dest = account,
            value = value or 5e8,
            bounce = false,
            flags = 0,
            payload = ""
        }
    }
    local signer = { WithKeys = funding_wallet.keys }
    local encoded = abi.encode_message(ctx, Abi, address, deploy_set, call_set, signer).await()
    local funded = false

    for request_id, params_json, response_type, finished
        in processing.process_message(ctx, encoded.message, Abi, false) do

        local result = json.decode(params_json)

        if not result then result = {} end

        for _, m in pairs(result.out_messages or {}) do
            if m.msg_type_name == "internal" then
                local data = net.wait_for_collection(
                    ctx, "transactions", { in_msg = { eq = m.id } }, "id", 60000).await()

                funded = data.id ~= nil
            end
        end
    end

    if not funded then
        error("failed to fund the account")
    end
end

function tt.fetch_account(ctx, account)
    local result = net.wait_for_collection(
        ctx, "accounts", { id = { eq = account } }, "id boc", 60000).await()

    return result
end

return tt

