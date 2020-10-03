describe("a processing test suite #processing", function()
    local context = require "context"
    local processing = require "processing"
    local client = require "client"
    local json = require "json"
    local tu = require "testutils"

    local ctx, message

    setup(function()
        local config = '{"network": {"server_address": "https://net.ton.dev"}}'

        ctx = context.create(config).handle
        message = tu:create_encoded_message(ctx, { WithKeys = tu.keys })
    end)

    teardown(function()
        context.destroy(ctx)
    end)

    describe("a processing.send_message", function()
        it("should send a message asynchronously", function()
            local sent = false
            local callback = function(request_id, result_json, error_json, flags)
                sent = json.decode(result_json or "{}").DidSend ~= nil
            end
            local callback_id = client.register_callback(ctx, "", callback)
            local result = processing.send_message(
                ctx, message, nil, { id = callback_id, stay_registered = false })

            tu.sleep(5)

            assert.is_true(sent)
        end)
    end)

    pending("a processing.process_message", function()
    end)

    pending("a processing.wait_for_transaction", function()
    end)
end)

