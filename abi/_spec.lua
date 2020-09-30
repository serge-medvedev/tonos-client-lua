local depool_abi = '{"ABI version":2,"header":["time","expire"],"functions":[{"name":"constructor","inputs":[{"name":"minRoundStake","type":"uint64"},{"name":"proxy0","type":"address"},{"name":"proxy1","type":"address"},{"name":"validatorWallet","type":"address"},{"name":"minStake","type":"uint64"}],"outputs":[]},{"name":"getParticipantInfo","inputs":[{"name":"addr","type":"address"}],"outputs":[{"name":"total","type":"uint64"},{"name":"withdrawValue","type":"uint64"},{"name":"reinvest","type":"bool"},{"name":"reward","type":"uint64"},{"name":"stakes","type":"map(uint64,uint64)"},{"components":[{"name":"isActive","type":"bool"},{"name":"amount","type":"uint64"},{"name":"lastWithdrawalTime","type":"uint64"},{"name":"withdrawalPeriod","type":"uint32"},{"name":"withdrawalValue","type":"uint64"},{"name":"owner","type":"address"}],"name":"vestings","type":"map(uint64,tuple)"},{"components":[{"name":"isActive","type":"bool"},{"name":"amount","type":"uint64"},{"name":"lastWithdrawalTime","type":"uint64"},{"name":"withdrawalPeriod","type":"uint32"},{"name":"withdrawalValue","type":"uint64"},{"name":"owner","type":"address"}],"name":"locks","type":"map(uint64,tuple)"}]},{"name":"getDePoolInfo","inputs":[],"outputs":[{"name":"minStake","type":"uint64"},{"name":"minRoundStake","type":"uint64"},{"name":"minValidatorStake","type":"uint64"},{"name":"validatorWallet","type":"address"},{"name":"proxies","type":"address[]"},{"name":"poolClosed","type":"bool"},{"name":"interest","type":"uint64"},{"name":"addStakeFee","type":"uint64"},{"name":"addVestingOrLockFee","type":"uint64"},{"name":"removeOrdinaryStakeFee","type":"uint64"},{"name":"withdrawPartAfterCompletingFee","type":"uint64"},{"name":"withdrawAllAfterCompletingFee","type":"uint64"},{"name":"transferStakeFee","type":"uint64"},{"name":"retOrReinvFee","type":"uint64"},{"name":"answerMsgFee","type":"uint64"},{"name":"proxyFee","type":"uint64"},{"name":"participantFraction","type":"uint64"},{"name":"validatorFraction","type":"uint64"},{"name":"validatorWalletMinStake","type":"uint64"}]},{"name":"getParticipants","inputs":[],"outputs":[{"name":"participants","type":"address[]"}]},{"name":"addOrdinaryStake","inputs":[{"name":"reinvest","type":"bool"}],"outputs":[]},{"name":"removeOrdinaryStake","inputs":[{"name":"withdrawValue","type":"uint64"}],"outputs":[]},{"name":"addVestingStake","inputs":[{"name":"beneficiary","type":"address"},{"name":"withdrawalPeriod","type":"uint32"},{"name":"totalPeriod","type":"uint32"}],"outputs":[]},{"name":"addLockStake","inputs":[{"name":"beneficiary","type":"address"},{"name":"withdrawalPeriod","type":"uint32"},{"name":"totalPeriod","type":"uint32"}],"outputs":[]},{"name":"withdrawPartAfterCompleting","inputs":[{"name":"withdrawValue","type":"uint64"}],"outputs":[]},{"name":"withdrawAllAfterCompleting","inputs":[{"name":"doWithdrawAll","type":"bool"}],"outputs":[]},{"name":"transferStake","inputs":[{"name":"dest","type":"address"},{"name":"amount","type":"uint64"}],"outputs":[]},{"name":"participateInElections","id":"0x4E73744B","inputs":[{"name":"queryId","type":"uint64"},{"name":"validatorKey","type":"uint256"},{"name":"stakeAt","type":"uint32"},{"name":"maxFactor","type":"uint32"},{"name":"adnlAddr","type":"uint256"},{"name":"signature","type":"bytes"}],"outputs":[]},{"name":"ticktock","inputs":[],"outputs":[]},{"name":"completeRoundWithChunk","inputs":[{"name":"roundId","type":"uint64"},{"name":"chunkSize","type":"uint8"}],"outputs":[]},{"name":"completeRound","inputs":[{"name":"roundId","type":"uint64"},{"name":"participantQty","type":"uint32"}],"outputs":[]},{"name":"onStakeAccept","inputs":[{"name":"queryId","type":"uint64"},{"name":"comment","type":"uint32"},{"name":"elector","type":"address"}],"outputs":[]},{"name":"onStakeReject","inputs":[{"name":"queryId","type":"uint64"},{"name":"comment","type":"uint32"},{"name":"elector","type":"address"}],"outputs":[]},{"name":"onSuccessToRecoverStake","inputs":[{"name":"queryId","type":"uint64"},{"name":"elector","type":"address"}],"outputs":[]},{"name":"onFailToRecoverStake","inputs":[{"name":"queryId","type":"uint64"},{"name":"elector","type":"address"}],"outputs":[]},{"name":"terminator","inputs":[],"outputs":[]},{"name":"receiveFunds","inputs":[],"outputs":[]},{"name":"getRounds","inputs":[],"outputs":[{"components":[{"name":"id","type":"uint64"},{"name":"supposedElectedAt","type":"uint32"},{"name":"unfreeze","type":"uint32"},{"name":"step","type":"uint8"},{"name":"completionReason","type":"uint8"},{"name":"participantQty","type":"uint32"},{"name":"stake","type":"uint64"},{"name":"rewards","type":"uint64"},{"name":"unused","type":"uint64"},{"name":"start","type":"uint64"},{"name":"end","type":"uint64"},{"name":"vsetHash","type":"uint256"}],"name":"rounds","type":"map(uint64,tuple)"}]}],"data":[],"events":[{"name":"dePoolPoolClosed","inputs":[],"outputs":[]},{"name":"roundStakeIsAccepted","inputs":[{"name":"queryId","type":"uint64"},{"name":"comment","type":"uint32"}],"outputs":[]},{"name":"roundStakeIsRejected","inputs":[{"name":"queryId","type":"uint64"},{"name":"comment","type":"uint32"}],"outputs":[]},{"name":"proxyHasRejectedTheStake","inputs":[{"name":"queryId","type":"uint64"}],"outputs":[]},{"name":"proxyHasRejectedRecoverRequest","inputs":[{"name":"roundId","type":"uint64"}],"outputs":[]},{"name":"RoundCompleted","inputs":[{"components":[{"name":"id","type":"uint64"},{"name":"supposedElectedAt","type":"uint32"},{"name":"unfreeze","type":"uint32"},{"name":"step","type":"uint8"},{"name":"completionReason","type":"uint8"},{"name":"participantQty","type":"uint32"},{"name":"stake","type":"uint64"},{"name":"rewards","type":"uint64"},{"name":"unused","type":"uint64"},{"name":"start","type":"uint64"},{"name":"end","type":"uint64"},{"name":"vsetHash","type":"uint256"}],"name":"round","type":"tuple"}],"outputs":[]},{"name":"stakeSigningRequested","inputs":[{"name":"electionId","type":"uint32"},{"name":"proxy","type":"address"}],"outputs":[]}]}'

pending("an abi test suite", function()
    local context = require "context"
    local abi= require "abi"
    local inspect = require "inspect"
    local json = require "json"

    local ctx

    setup(function()
        local config = '{"network": {"server_address": "https://net.ton.dev"}}'

        ctx = context.create(config).handle
    end)

    teardown(function()
        context.destroy(ctx)
    end)

    describe("an abi.encode_message", function()
        it("should return a BOC", function()
            local result = abi.encode_message(
                ctx,
                json.decode(depool_abi),
                "0:c0eacef24f7811cec9fa129f2e301287e45dc3bac8175eb7121a7e7f5e76be11")

            print(inspect(result))
        end)
    end)

    describe("an abi.decode_message", function()
        it("should return parsed value", function()
            local result = abi.decode_message(ctx, json.decode(depool_abi), "te6ccgEBAQEABgAACCiAmCM=")

            print(inspect(result))
        end)
    end)
end)

