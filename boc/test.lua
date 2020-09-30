package.path = "../?.lua;" .. package.path

local context = require "context"
local boc = require "boc"
local inspect = require "inspect"

function lookup(t, ...)
	for _, k in ipairs{...} do
		t = t[k]
		if not t then
			return nil
		end
	end

	return t
end

local config = '{"network": {"server_address": "https://net.ton.dev"}}'
local ctx = context.create(config).handle

do  print("Testing boc.parse_message")

    local result = boc.parse_message(
        ctx,"te6ccgEBAQEAXgAAt0gB/PsFspR1bdPkaI977UhHxBvawyoDizKfgwSkeV23aPsAHhm5eTtxAY5MxFAgH0qLcfUvFMAW7NNcUKM3SUMkbQEcTyeKvZiAAAYUWGAAAAmASvR6yL7WlMRA")

    assert(lookup(result,"parsed", "value") == "0x13c9e2af662000")
end

context.destroy(ctx)

