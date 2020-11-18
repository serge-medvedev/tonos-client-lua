#!/usr/bin/env lua

local json = require "dkjson"
local lib = require("tonos.client")
local context = lib.context
local processing = lib.processing
local config = '{"network":{"server_address":"https://net.ton.dev"}}'
local wallet_abi = '{"ABI version":2,"header":["pubkey","time","expire"],"functions":[{"name":"sendTransaction","inputs":[{"name":"dest","type":"address"},{"name":"value","type":"uint128"},{"name":"bounce","type":"bool"},{"name":"flags","type":"uint8"},{"name":"payload","type":"cell"}],"outputs":[]}],"data":[],"events":[]}'
local my_wallet = {
    addr = "...",
    keys = {
        public = "...",
        secret = "..."
    }
}
local coffee_shop = "0:81236e4b0298f55b1d4d67d0f508cffa21466f42f646a829ff68ea4562f832bc"
local ctx = context.create(config)

local function send_money(from, to, nanotons, keys)
    local now = os.time(os.date("!*t"))
    local params = {
        message_encode_params = {
            abi = {
                type = "Json",
                value = wallet_abi
            },
            address = from,
            call_set = {
                function_name = "sendTransaction",
                header = {
                    pubkey = keys.public,
                    time = now * 1000,
                    expire = now + 10
                },
                input = {
                    dest = to,
                    value = nanotons,
                    bounce = false,
                    flags = 0,
                    payload = ""
                }
            },
            signer = {
                type = "Keys",
                keys = keys
            }
        },
        send_events = true
    }

    for request_id, params_json, response_type, finished
        in processing.process_message(ctx, params) do

        local result = json.decode(params_json)

        if response_type == 1 then
            print("ERROR:", result.message)
        end

        if not result then result = {} end

        if result.transaction and result.transaction.status_name == "finalized" then
            print("Money sent")
        end
    end
end

send_money(my_wallet.addr, coffee_shop, 1e9, my_wallet.keys)

context.destroy(ctx)

return 0

