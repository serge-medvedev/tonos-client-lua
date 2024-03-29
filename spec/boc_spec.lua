describe("a boc test suite #boc", function()
    local lib = require "tonos.client"
    local context = lib.context
    local boc = lib.boc
    local tt = require "spec.tools"

    local ctx

    setup(function()
        local config = '{"network": {"server_address": "https://mainnet.evercloud.dev/d61ac7417de44bdbb5446a4efe0690c7"}}'

        ctx = context.create(config)
    end)

    teardown(function()
        context.destroy(ctx)
    end)

    describe("a boc.parse_transaction", function()
        it("should return a parsed balance delta", function()
            local params = {
                boc = tt.data.boc.transaction
            }
            local result = boc.parse_transaction(ctx, params).await().parsed

            assert.equals("0x9d350e60", result.balance_delta)
        end)
    end)

    describe("a boc.parse_block", function()
        it("should return a parsed seq_no", function()
            local params = {
                boc = tt.data.boc.block
            }
            local result = boc.parse_block(ctx, params).await().parsed

            assert.equals(4810902, result.seq_no)
        end)
    end)

    describe("a boc.parse_account", function()
        it("should return a parsed account id", function()
            local params = {
                boc = tt.data.boc.account
            }
            local result = boc.parse_account(ctx, params).await().parsed

            assert.equals("0:7866e5e4edc40639331140807d2a2dc7d4bc53005bb34d71428cdd250c91b404", result.id)
        end)
    end)

    describe("a boc.parse_message", function()
        it("should return a parsed value", function()
            local params = {
                boc = tt.data.boc.message
            }
            local result = boc.parse_message(ctx, params).await().parsed

            assert.equals("0x13c9e2af662000", result.value)
        end)
    end)

    describe("a boc.get_boc_hash", function()
        it("should return a parsed value", function()
            local params = {
                boc = "te6ccgEBAQEAWAAAq2n+AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAE/zMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzSsG8DgAAAAAjuOu9NAL7BxYpA"
            }
            local result = boc.get_boc_hash(ctx, params).await()

            assert.equals("dfd47194f3058ee058bfbfad3ea40cbbd9ad17ca77cd0904d4d9f18a48c2fbca", result.hash)
        end)
    end)

    describe("a boc.parse_shardstate", function()
        it("should return a parsed value", function()
            local params = {
                boc = tt.data.boc.shardstate,
                workchain_id = -1,
                id = "zerostate:-1"
            }
            local result = boc.parse_shardstate(ctx, params).await().parsed

            assert.equals(params.id, result.id)
            assert.equals(params.workchain_id, result.workchain_id)
            assert.equals(0, result.seq_no)
        end)
    end)

    describe("a boc.get_blockchain_config", function()
        it("should return a config", function()
            local params = {
                block_boc = tt.data.boc.blockchain
            }
            local result = boc.get_blockchain_config(ctx, params).await()

            assert.is_not_nil(result.config_boc)
        end)
    end)

    describe("a boc.encode_boc", function()
        local json = require "dkjson"

        it("should create a valid boc out of parts", function()
            local write_b = function(value)
                return {
                    type = "Integer",
                    size = 1,
                    value = value
                }
            end

            local write_u128 = function(value) -- expects string
                return {
                    type = "Integer",
                    size = 128,
                    value = value
                }
            end

            local write_i = function(value, size)
                return {
                    type = "Integer",
                    size = size,
                    value = value
                }
            end

            local write_i8 = function(value)
                return write_i(value, 8)
            end

            local write_u8 = write_i8

            local write_bitstring = function(value)
                return {
                    type = "BitString",
                    value = value
                }
            end

            local write_cell = function(write)
                return {
                    type = "Cell",
                    builder = write
                }
            end

            local expected_boc = "te6ccgEBAgEAKQABL7/f4EAAAAAAAAAAAG2m0us0F8ViiEjLZAEAF7OJx0AnACRgJH/bsA=="

            local params = {
                builder = {
                    write_b(1),
                    write_b(0),
                    write_u8(255),
                    write_i8(127),
                    write_i8(-127),
                    write_u128("123456789123456789"),
                    write_bitstring("8A_"),
                    write_bitstring("x{8A0_}"),
                    write_bitstring("123"),
                    write_bitstring("x2d9_"),
                    write_bitstring("80_"),
                    write_cell({
                        write_bitstring("n101100111000"),
                        write_bitstring("N100111000"),
                        write_i(-1, 3),
                        write_i(2, 3),
                        write_i(312, 16),
                        write_i("0x123", 16),
                        write_i("0x123", 16),
                        write_i("-0x123", 16),
                    })
                }
            }

            local result = boc.encode_boc(ctx, params).await()

            assert.equals(expected_boc, result.boc)

            params = {
                builder = {
                    write_b(1),
                    write_b(0),
                    write_u8(255),
                    write_i8(127),
                    write_i8(-127),
                    write_u128("123456789123456789"),
                    write_bitstring("8A_"),
                    write_bitstring("x{8A0_}"),
                    write_bitstring("123"),
                    write_bitstring("x2d9_"),
                    write_bitstring("80_"),
                    {
                        type = "CellBoc",
                        boc = "te6ccgEBAQEADgAAF7OJx0AnACRgJH/bsA=="
                    }
                }
            }

            result = boc.encode_boc(ctx, params).await()

            assert.equals(expected_boc, result.boc)
        end)
    end)
end)
