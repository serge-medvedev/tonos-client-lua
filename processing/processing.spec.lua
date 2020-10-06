describe("a processing test suite #processing", function()
    local context = require "context"
    local processing = require "processing"
    local client = require "client"
    local json = require "json"
    local tu = require "testutils"
    local inspect = require "inspect"

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
                ctx, message, { id = callback_id, stay_registered = false }, tu.abi)

            tu.sleep(5)

            assert.is_true(sent)
        end)
    end)

    pending("a processing.wait_for_transaction", function()
        it("should wait for a transaction", function()
        end)
    end)

    pending("a processing.process_message", function()
        it("should process a message asynchronously", function()
            local callback = function(request_id, result_json, error_json, flags)
                print(inspect({ request_id = request_id, result_json = result_json, error_json = error_json, flags = flags }))
            end
            local callback_id = client.register_callback(ctx, "", callback)
            local result = processing.process_message(
                ctx,
                { message = message, abi = tu.abi },
                { id = callback_id, stay_registered = false })

            tu.sleep(5)

            client.unregister_callback(ctx, callback_id)

            print(inspect(result))
        end)
    end)

    pending("a processing.wait_for_transaction", function()
    end)
end)

