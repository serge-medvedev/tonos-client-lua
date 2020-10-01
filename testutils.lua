local abi = require "abi"
local json = require "json"

local tu = {}

tu.keys = {
    public = "134c67910aa0bd4410e0b62379d517af13df99ba04764bca06e0ba86c736b80a",
    secret = "ddf87be7c470ea26811e5ef86391cb97d79afb35098753c2f990c2b0aef5223d"
}
tu.events_abi = '{"ABI version":2,"header":["pubkey","time","expire"],"functions":[{"name":"emitValue","inputs":[{"name":"id","type":"uint256"}],"outputs":[]},{"name":"returnValue","inputs":[{"name":"id","type":"uint256"}],"outputs":[{"name":"value0","type":"uint256"}]},{"name":"sendAllMoney","inputs":[{"name":"dest_addr","type":"address"}],"outputs":[]},{"name":"constructor","inputs":[],"outputs":[]}],"data":[],"events":[{"name":"EventThrown","inputs":[{"name":"id","type":"uint256"}],"outputs":[]}]}'
tu.tvc = "te6ccgECFwEAAxUAAgE0BgEBAcACAgPPIAUDAQHeBAAD0CAAQdgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAIm/wD0pCAiwAGS9KDhiu1TWDD0oQkHAQr0pCD0oQgAAAIBIAwKAcj/fyHtRNAg10nCAY4Q0//TP9MA0X/4Yfhm+GP4Yo4Y9AVwAYBA9A7yvdcL//hicPhjcPhmf/hh4tMAAY4dgQIA1xgg+QEB0wABlNP/AwGTAvhC4iD4ZfkQ8qiV0wAB8nri0z8BCwBqjh74QyG5IJ8wIPgjgQPoqIIIG3dAoLnekvhj4IA08jTY0x8B+CO88rnTHwHwAfhHbpLyPN4CASASDQIBIA8OAL26i1Xz/4QW6ONe1E0CDXScIBjhDT/9M/0wDRf/hh+Gb4Y/hijhj0BXABgED0DvK91wv/+GJw+GNw+GZ/+GHi3vhG8nNx+GbR+AD4QsjL//hDzws/+EbPCwDJ7VR/+GeAIBIBEQAOW4gAa1vwgt0cJ9qJoaf/pn+mAaL/8MPwzfDH8MW99IMrqaOh9IG/o/CKQN0kYOG98IV15cDJ8AGRk/YIQZGfChGdGggQH0AAAAAAAAAAAAAAAAAAgZ4tkwIBAfYAYfCFkZf/8IeeFn/wjZ4WAZPaqP/wzwAMW5k8Ki3wgt0cJ9qJoaf/pn+mAaL/8MPwzfDH8MW9rhv/K6mjoaf/v6PwAZEXuAAAAAAAAAAAAAAAACGeLZ8DnyOPLGL0Q54X/5Lj9gBh8IWRl//wh54Wf/CNnhYBk9qo//DPACAUgWEwEJuLfFglAUAfz4QW6OE+1E0NP/0z/TANF/+GH4Zvhj+GLe1w3/ldTR0NP/39H4AMiL3AAAAAAAAAAAAAAAABDPFs+Bz5HHljF6Ic8L/8lx+wDIi9wAAAAAAAAAAAAAAAAQzxbPgc+SVviwSiHPC//JcfsAMPhCyMv/+EPPCz/4Rs8LAMntVH8VAAT4ZwBy3HAi0NYCMdIAMNwhxwCS8jvgIdcNH5LyPOFTEZLyO+HBBCKCEP////28sZLyPOAB8AH4R26S8jze"

function tu:create_encoded_message(ctx, signer)
    local result = abi.encode_message(
        ctx,
        { Serialized = json.decode(self.events_abi) },
        nil,
        { tvc = self.tvc },
        { function_name = "constructor",
          header = { pubkey = self.keys.public, time = 1599458364291, expire = 1599458404 } },
        signer)

    return result.message
end

return tu

