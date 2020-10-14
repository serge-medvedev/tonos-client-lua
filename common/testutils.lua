local abi = require "abi"
local net = require "net"
local processing = require "processing"
local json = require "dkjson"
local inspect = require "inspect"

local tu = {}

function tu.sleep(n)
    os.execute("sleep " .. tonumber(n))
end

function tu.timestamp()
    return os.time()
end

function tu.lookup(t, ...)
    for _, k in ipairs{...} do
        t = t[k]
        if not t then
            return nil
        end
    end

    return t
end

tu.inspect = inspect

tu.funding_wallet_address = "0:e745f4d86672dccd4c6270bfb23be02481aa65814a40f7edd74d3940f7a891fb"
tu.funding_wallet_keys = {
    public = "e8892ab5ce75c6800a259302b97c4c9f40b65a1251b6791f07ac9cc4ef1e3527",
    secret = "a474157eb56864cec881b1bd2569ca3fdce30d9be101346208f507ecdb34a8dc"
}
tu.keys = {
    public = "134c67910aa0bd4410e0b62379d517af13df99ba04764bca06e0ba86c736b80a",
    secret = "ddf87be7c470ea26811e5ef86391cb97d79afb35098753c2f990c2b0aef5223d"
}
tu.events_abi = '{"ABI version":2,"header":["pubkey","time","expire"],"functions":[{"name":"emitValue","inputs":[{"name":"id","type":"uint256"}],"outputs":[]},{"name":"returnValue","inputs":[{"name":"id","type":"uint256"}],"outputs":[{"name":"value0","type":"uint256"}]},{"name":"sendAllMoney","inputs":[{"name":"dest_addr","type":"address"}],"outputs":[]},{"name":"constructor","inputs":[],"outputs":[]}],"data":[],"events":[{"name":"EventThrown","inputs":[{"name":"id","type":"uint256"}],"outputs":[]}]}'
tu.funding_wallet_abi = '{"ABI version":2,"header":["pubkey","time","expire"],"functions":[{"name":"constructor","inputs":[{"name":"owners","type":"uint256[]"},{"name":"reqConfirms","type":"uint8"}],"outputs":[]},{"name":"acceptTransfer","inputs":[{"name":"payload","type":"bytes"}],"outputs":[]},{"name":"sendTransaction","inputs":[{"name":"dest","type":"address"},{"name":"value","type":"uint128"},{"name":"bounce","type":"bool"},{"name":"flags","type":"uint8"},{"name":"payload","type":"cell"}],"outputs":[]},{"name":"submitTransaction","inputs":[{"name":"dest","type":"address"},{"name":"value","type":"uint128"},{"name":"bounce","type":"bool"},{"name":"allBalance","type":"bool"},{"name":"payload","type":"cell"}],"outputs":[{"name":"transId","type":"uint64"}]},{"name":"confirmTransaction","inputs":[{"name":"transactionId","type":"uint64"}],"outputs":[]},{"name":"isConfirmed","inputs":[{"name":"mask","type":"uint32"},{"name":"index","type":"uint8"}],"outputs":[{"name":"confirmed","type":"bool"}]},{"name":"getParameters","inputs":[],"outputs":[{"name":"maxQueuedTransactions","type":"uint8"},{"name":"maxCustodianCount","type":"uint8"},{"name":"expirationTime","type":"uint64"},{"name":"minValue","type":"uint128"},{"name":"requiredTxnConfirms","type":"uint8"},{"name":"requiredUpdConfirms","type":"uint8"}]},{"name":"getTransaction","inputs":[{"name":"transactionId","type":"uint64"}],"outputs":[{"components":[{"name":"id","type":"uint64"},{"name":"confirmationsMask","type":"uint32"},{"name":"signsRequired","type":"uint8"},{"name":"signsReceived","type":"uint8"},{"name":"creator","type":"uint256"},{"name":"index","type":"uint8"},{"name":"dest","type":"address"},{"name":"value","type":"uint128"},{"name":"sendFlags","type":"uint16"},{"name":"payload","type":"cell"},{"name":"bounce","type":"bool"}],"name":"trans","type":"tuple"}]},{"name":"getTransactions","inputs":[],"outputs":[{"components":[{"name":"id","type":"uint64"},{"name":"confirmationsMask","type":"uint32"},{"name":"signsRequired","type":"uint8"},{"name":"signsReceived","type":"uint8"},{"name":"creator","type":"uint256"},{"name":"index","type":"uint8"},{"name":"dest","type":"address"},{"name":"value","type":"uint128"},{"name":"sendFlags","type":"uint16"},{"name":"payload","type":"cell"},{"name":"bounce","type":"bool"}],"name":"transactions","type":"tuple[]"}]},{"name":"getTransactionIds","inputs":[],"outputs":[{"name":"ids","type":"uint64[]"}]},{"name":"getCustodians","inputs":[],"outputs":[{"components":[{"name":"index","type":"uint8"},{"name":"pubkey","type":"uint256"}],"name":"custodians","type":"tuple[]"}]},{"name":"submitUpdate","inputs":[{"name":"codeHash","type":"uint256"},{"name":"owners","type":"uint256[]"},{"name":"reqConfirms","type":"uint8"}],"outputs":[{"name":"updateId","type":"uint64"}]},{"name":"confirmUpdate","inputs":[{"name":"updateId","type":"uint64"}],"outputs":[]},{"name":"executeUpdate","inputs":[{"name":"updateId","type":"uint64"},{"name":"code","type":"cell"}],"outputs":[]},{"name":"getUpdateRequests","inputs":[],"outputs":[{"components":[{"name":"id","type":"uint64"},{"name":"index","type":"uint8"},{"name":"signs","type":"uint8"},{"name":"confirmationsMask","type":"uint32"},{"name":"creator","type":"uint256"},{"name":"codeHash","type":"uint256"},{"name":"custodians","type":"uint256[]"},{"name":"reqConfirms","type":"uint8"}],"name":"updates","type":"tuple[]"}]}],"data":[],"events":[{"name":"TransferAccepted","inputs":[{"name":"payload","type":"bytes"}],"outputs":[]}]}'
tu.tvc = "te6ccgECFwEAAxUAAgE0BgEBAcACAgPPIAUDAQHeBAAD0CAAQdgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAIm/wD0pCAiwAGS9KDhiu1TWDD0oQkHAQr0pCD0oQgAAAIBIAwKAcj/fyHtRNAg10nCAY4Q0//TP9MA0X/4Yfhm+GP4Yo4Y9AVwAYBA9A7yvdcL//hicPhjcPhmf/hh4tMAAY4dgQIA1xgg+QEB0wABlNP/AwGTAvhC4iD4ZfkQ8qiV0wAB8nri0z8BCwBqjh74QyG5IJ8wIPgjgQPoqIIIG3dAoLnekvhj4IA08jTY0x8B+CO88rnTHwHwAfhHbpLyPN4CASASDQIBIA8OAL26i1Xz/4QW6ONe1E0CDXScIBjhDT/9M/0wDRf/hh+Gb4Y/hijhj0BXABgED0DvK91wv/+GJw+GNw+GZ/+GHi3vhG8nNx+GbR+AD4QsjL//hDzws/+EbPCwDJ7VR/+GeAIBIBEQAOW4gAa1vwgt0cJ9qJoaf/pn+mAaL/8MPwzfDH8MW99IMrqaOh9IG/o/CKQN0kYOG98IV15cDJ8AGRk/YIQZGfChGdGggQH0AAAAAAAAAAAAAAAAAAgZ4tkwIBAfYAYfCFkZf/8IeeFn/wjZ4WAZPaqP/wzwAMW5k8Ki3wgt0cJ9qJoaf/pn+mAaL/8MPwzfDH8MW9rhv/K6mjoaf/v6PwAZEXuAAAAAAAAAAAAAAAACGeLZ8DnyOPLGL0Q54X/5Lj9gBh8IWRl//wh54Wf/CNnhYBk9qo//DPACAUgWEwEJuLfFglAUAfz4QW6OE+1E0NP/0z/TANF/+GH4Zvhj+GLe1w3/ldTR0NP/39H4AMiL3AAAAAAAAAAAAAAAABDPFs+Bz5HHljF6Ic8L/8lx+wDIi9wAAAAAAAAAAAAAAAAQzxbPgc+SVviwSiHPC//JcfsAMPhCyMv/+EPPCz/4Rs8LAMntVH8VAAT4ZwBy3HAi0NYCMdIAMNwhxwCS8jvgIdcNH5LyPOFTEZLyO+HBBCKCEP////28sZLyPOAB8AH4R26S8jze"

function tu:create_encoded_message(ctx, signer, time, expire)
    local pubkey = self.keys.public

    if signer.WithKeys then
        pubkey = signer.WithKeys.public
    elseif signer.External then
        pubkey = signer.External
    end

    return abi.encode_message(
        ctx,
        { Serialized = json.decode(self.events_abi) },
        nil,
        { tvc = self.tvc },
        { function_name = "constructor",
          header = { pubkey = pubkey, time = time, expire = expire } },
        signer)
end

function tu.print_callback_args(request_id, params_json, response_type, finished)
    print(inspect({
        request_id = request_id,
        params_json = params_json,
        response_type = response_type,
        finished = finished
    }))
end

function tu:fund_account(ctx, account, value)
    local Abi = { Serialized = json.decode(self.funding_wallet_abi) }
    local address = self.funding_wallet_address
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
    local signer = { WithKeys = self.funding_wallet_keys }
    local encoded = abi.encode_message(ctx, Abi, address, deploy_set, call_set, signer)
    local funded = false

    for request_id, params_json, response_type, finished
        in processing.process_message(ctx, { message = encoded.message, abi = Abi }, false) do

        local succeeded, result = pcall(json.decode, params_json)

        if not succeeded then result = {} end

        for _, m in pairs(result.out_messages or {}) do
            if m.msg_type_name == "internal" then
                local data = net.wait_for_collection(
                    ctx, "transactions", { in_msg = { eq = m.id } }, "id", 60000)

                funded = self.lookup(data, "result", "id") ~= nil
            end
        end
    end

    if not funded then
        error("failed to fund the account")
    end
end

return tu

