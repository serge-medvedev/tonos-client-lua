describe("a boc test suite", function()
	local context = require "context"
	local boc = require "boc"

	function lookup(t, ...)
		for _, k in ipairs{...} do
			t = t[k]
			if not t then
				return nil
			end
		end

		return t
	end

	local ctx

	setup(function()
		local config = '{"network": {"server_address": "https://main.ton.dev"}}'

		ctx = context.create(config).handle
	end)

	teardown(function()
		context.destroy(ctx)
	end)

	describe("a boc.parse_transaction", function()
		it("should return a parsed balance delta", function()
			local result = boc.parse_transaction(
				ctx,
				"te6ccgECBwEAAYkAA69zMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzAAAFBBTNMcI8f1y6WqRCRXolpb3RxYWNMvBbuGIwucQIH+5RTHOlWAAABQQUzTHBX3UOnQABQIBQQBAg8ECSdNQ5gYEQMCAFvAAAAAAAAAAAAAAAABLUUtpEnlC4z33SeGHxRhIq/htUa7i3D8ghbwxhQTn44EAJ5Cr2wQGRgAAAAAAAAAAGQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIJyqiOYFoD7s8xp2FNsGMTztTqdTJnF3dlvZVOuSr0pf2Ce205KG0MKT+jFigBpMM4ga58Ajv+ZdbN+rqfqUUAEAAEBoAYAq2n+AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAE/zMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzSdNQ5gAAAAAoIKZpjgL7qHTpA")
			local parsed_balance_delta = lookup(result, "parsed", "balance_delta")

			assert.equals("0x9d350e60", parsed_balance_delta)
		end)
	end)

	describe("a boc.parse_block", function()
		it("should return a parsed seq_no", function()
			local result = boc.parse_block(
				ctx,
				"te6ccuECFAEAA5oAABwAxADeAXACBAKgAzwDXgNwA9YEPASIBWIFegWRBmoG2gcmBy4HNQQQEe9VqgAAACoBAgMEAqCbx6mHAAAAAIQBAElolgAAAAAEAAAAAKAAAAAAAAAAX3UOVgAABQQSxmVAAAAFBBLGZUGE+1CjAAC/3gA1EuMANP4xxAAAAAQAAAAAAAAALgUGAhG45I37QDuaygQHCAqKBDdu9VqKhsC8UsmjMYJtAe3uWVUL/RrdEYaY1NPxzNHhVtKatKfUP6+trYYGMypaxvJNmcx0e3TP5wNf41NKn0wAGwAbCQoDiUoz9v0dOVZbcd9ViLGntvgnlxtUjh2u+1Ut5xaXBIsWwTKLpzRYOx6OHBf5zvLaB3i3g8YI0gRPmNIfl6tTDQdSw/bEQBITEwCYAAAFBBK3IwQANRLj3QMTL310TEzKUALP6uqQ6UqJlxBTfJGNCQgm05p9JlqfzpHR6TJwmHWnZQdL1/Wmz80Ln2HGm28j0xd3M7qFsQCYAAAFBBK3IwEASWiVZa2eBFtCgwpswZCJZuYcPdpDlbJoVwvJzEQG5KxyvbTOHdr9+j8Ot9tdTHl2pdXK9j+8pUHtOMDLmuGbrqAMuwAdaHqdr/Kjk0PU7X+VHIAIAA0AEA7msoAII1uQI6/iAAAAKgQAAAAAoAAAAAAAAAAASWiVAAAAAF91DlMAAAUEErcjAQA1EuIgCw4MI1uQI6/iAAAAKgQAAAAAoAAAAAAAAAAASWiWAAAAAF91DlYAAAUEEsZlQQA1EuMgDQ4PKEgBAblZ7PBy//5rdt17gIBQpna0Y6CqY8nrNO6C6S07pYt/AAEA1QAAAAAAAAAA//////////9oep2v8qOTgIi9/ZTTJRAAAFBBKYnoQANRLiOHld8Y1pT9/tedhgqFz4vWaABnLcp67Dhgt6C71XWUBicrYxUaFIDML1oBLBkblabCNuyeu3zMc02Workkim5IAREAAAAAAAAAAFAQIQ+Boep2v8qOUBEA1QAAAAAAAAAA//////////9oep2v8qOTgIi9/3GpdRAAAFBBK3IwQANRLj3QMTL310TEzKUALP6uqQ6UqJlxBTfJGNCQgm05p9JlqfzpHR6TJwmHWnZQdL1/Wmz80Ln2HGm28j0xd3M7qFsYAGuwVAAAAAAAAAAAGolxgAACgglbkYH//////////////////////////////////////////8AoSAEBVL8S9heCm76YB96GlvklvvuL2U0fsDcdrxi2jb7CqDAAGQADACAAAQLAcM1t")
			local parsed_seq_no = lookup(result, "parsed", "seq_no")

			assert.equals(4810902, parsed_seq_no)
		end)
	end)

	describe("a boc.parse_account", function()
		it("should return a parsed account id", function()
			local result = boc.parse_account(
				ctx,
				"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")
			local parsed_id = lookup(result, "parsed", "id")

			assert.equals("0:7866e5e4edc40639331140807d2a2dc7d4bc53005bb34d71428cdd250c91b404", parsed_id)
		end)
	end)

	describe("a boc.parse_message", function()
		it("should return a parsed value", function()
			local result = boc.parse_message(
				ctx,
				"te6ccgEBAQEAXgAAt0gB/PsFspR1bdPkaI977UhHxBvawyoDizKfgwSkeV23aPsAHhm5eTtxAY5MxFAgH0qLcfUvFMAW7NNcUKM3SUMkbQEcTyeKvZiAAAYUWGAAAAmASvR6yL7WlMRA")
			local parsed_value = lookup(result, "parsed", "value")

			assert.equals("0x13c9e2af662000", parsed_value)
		end)
	end)
end)

