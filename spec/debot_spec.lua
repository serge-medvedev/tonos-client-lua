local say = require "say"

local function multimatch(state, arguments)
    if not type(arguments) == "table" or #arguments ~= 2 then
        return false
    end

    local result, vs, ts = true, arguments[1], arguments[2]

    if not (type(vs) == "table" and type(ts) == "table") or (#vs ~= #ts) then
        return false
    end

    local result = true

    for i, v in ipairs(vs) do
        resut = result and (string.match(v, ts[i]) ~= nil)

        if not result then
            break
        end
    end

    return result
end

say:set("assertion.multimatch.positive", "Expected '%s' to match '%s'")
say:set("assertion.multimatch.negative", "Expected '%s' to not match '%s'")
assert:register("assertion", "multimatch", multimatch, "assertion.multimatch.positive", "assertion.multimatch.negative")

describe("a debot test suite #debot #paid #heavy", function()
    local json = require "dkjson"
    local sched = require "lumen.sched"
    local tt = require "spec.tools"
    local lib = require "tonos.client"
    local abi, client, context, crypto, debot, processing = lib.abi, lib.client, lib.context, lib.crypto, lib.debot, lib.processing

    local function init_debot(ctx)
        local keys = crypto.generate_random_sign_keys(ctx).await()
        local signer = { type = "Keys", keys = keys }
        local target_deploy_params = {
            abi = { type = "Json", value = tt.data.debot.target.abi },
            deploy_set = { tvc = tt.data.debot.target.tvc },
            call_set = {
                function_name = "constructor"
            },
            signer = signer
        }
        local target_deploy_encoded = abi.encode_message(ctx, target_deploy_params).await()
        local target_addr = target_deploy_encoded.address

        tt.fund_account(ctx, target_addr)
        processing.process_message(ctx, { message_encode_params = target_deploy_params, send_events = false }).await()

        local debot_deploy_params = {
            abi = { type = "Json", value = tt.data.debot.abi },
            deploy_set = { tvc = tt.data.debot.tvc },
            call_set = {
                function_name = "constructor",
                input = {
                    debotAbi = tt.tohex(tt.data.debot.abi),
                    targetAbi = tt.tohex(tt.data.debot.target.abi),
                    targetAddr = target_addr
                }
            },
            signer = signer
        }
        local debot_deploy_encoded = abi.encode_message(ctx, debot_deploy_params).await()
        local debot_addr = debot_deploy_encoded.address

        tt.fund_account(ctx, debot_addr)
        processing.process_message(ctx, { message_encode_params = debot_deploy_params, send_events = false }).await()

        return debot_addr, target_addr, keys
    end

    local ctx, debot_addr, target_addr, keys

    setup(function()
        local config = '{"network": {"server_address": "https://net.ton.dev"}}'

        ctx = context.create(config)
    end)

    before_each(function()
        debot_addr, target_addr, keys = init_debot(ctx)
    end)

    teardown(function()
        context.destroy(ctx)
    end)

    local function prune(t)
        while next(t) do
            table.remove(t)
        end
    end

    local function check(steps)
        local function invoke_debot(inputs, outputs, available_actions, address, start_or_fetch)
            local debot_handle

            for request_id, params_json, response_type, finished
                in debot[start_or_fetch](ctx, { address = address }) do

                -- print(json.encode({
                --     request_id = request_id,
                --     params_json = params_json,
                --     response_type = response_type,
                --     finished = finished
                -- }, { indent = true }))

                local params = json.decode(params_json)

                if response_type == 0 then
                    debot_handle = params.debot_handle

                    sched.schedule_signal("debot_handle", debot_handle)
                elseif response_type == 2 then
                    -- do nothing
                elseif response_type == 3 then -- AppRequest
                    local result = {}

                    if params.request_data.type == "Input" then
                        local value = table.remove(inputs, 1)

                        result.type = "Input"
                        result.value = value
                    elseif params.request_data.type == "GetSigningBox" then
                        local signing_box = crypto.get_signing_box(ctx, keys).await()

                        result.type = "GetSigningBox"
                        result.signing_box = signing_box.handle
                    elseif params.request_data.type == "InvokeDebot" then
                        sched.schedule_signal("invocation", params.request_data)

                        result.type = "InvokeDebot"
                    else
                        error(string.format("invalid call %s", params_json))
                    end

                    local resolve_app_request_params = {
                        app_request_id = params.app_request_id,
                        result = {
                            type = "Ok",
                            result = result
                        }
                    }

                    -- print(string.format("resolving app request with %s", json.encode(resolve_app_request_params, { indent = true })))

                    client.resolve_app_request(ctx, resolve_app_request_params).await()
                elseif response_type == 4 then -- AppNotify
                    if params.type == "Log" then
                        table.insert(outputs, params.msg)
                    elseif params.type == "Switch" then
                        prune(available_actions)
                    elseif params.type == "ShowAction" then
                        table.insert(available_actions, params.action)
                    elseif params.type == "SwitchCompleted" then
                        -- TODO: utilize it
                    else
                        error(string.format("invalid notification %s", params_json))
                    end
                else
                    error(string.format("Wrong response type [response_type = %u] - %s",
                        response_type, json.encode(params, { indent = true })))
                end

                if not finished then
                    sched.wait()
                end
            end
        end

        local function walk(inputs, outputs, available_actions, steps)
            local _, debot_handle = sched.wait({ "debot_handle" })
            local finishers = {}

            while steps[1] do
                local step = table.remove(steps, 1)

                -- print("step:", json.encode(step, { indent = true }))

                while not available_actions[step.choice] do
                    sched.wait()
                end

                local action = available_actions[step.choice]

                -- print(string.format("action to execute: %s", json.encode(action)))

                for _, input in ipairs(step.inputs) do
                    table.insert(inputs, input)
                end

                prune(outputs)

                -- non-blocking call, must be await'ed for the clean up
                -- TODO: come up with a way of dealing with dangling return values automatically (__gc hook?)
                local f = debot.execute(ctx, { debot_handle = debot_handle, action = action })

                table.insert(finishers, f)

                while #outputs < #step.outputs do
                    sched.wait()
                end

                assert.multimatch(step.outputs, outputs)

                if step.invokes then
                    local _, request_data = sched.wait({ "invocation" })
                    local inputs, outputs, available_actions = {}, {}, { request_data.action }

                    sched.run(function()
                        invoke_debot(inputs, outputs, available_actions, request_data.debot_addr, "fetch")
                    end)
                    sched.run(function()
                        walk(inputs, outputs, available_actions, tt.clone(step.invokes[1]))
                    end)
                end
            end

            debot.remove(ctx, { debot_handle = debot_handle }).await()

            for _, f in ipairs(finishers) do
                f.await()
            end
        end

        local inputs, outputs, available_actions = {}, {}, {}

        sched.run(function()
            invoke_debot(inputs, outputs, available_actions, debot_addr, "start")
        end)
        sched.run(function()
            walk(inputs, outputs, available_actions, tt.clone(steps))
        end)

        sched.loop()
    end

    describe("a few debot usage scenarios", function()
        it("debot.goto", function()
            local steps = {
                { choice = 1, inputs = {}, outputs = { "Test Goto Action" } },
                { choice = 1, inputs = {}, outputs = { "Debot Tests" } },
                { choice = 8, inputs = {}, outputs = {} }
            }

            check(steps)
        end)

        it("debot.print", function()
            local steps = {
                { choice = 2, inputs = {}, outputs = { "Test Print Action", "test2: instant print", "test instant print" } },
                { choice = 1, inputs = {}, outputs = { "test simple print" } },
                { choice = 2, inputs = {}, outputs = { string.format("integer=1,addr=%s,string=test_string_1", target_addr) } },
                { choice = 3, inputs = {}, outputs = { "Debot Tests" } },
                { choice = 8, inputs = {}, outputs = {} }
            }

            check(steps)
        end)

        it("debot.run", function()
            local steps = {
                {
                    choice = 3,
                    inputs = { "-1:1111111111111111111111111111111111111111111111111111111111111111" },
                    outputs = { "Test Run Action", "test1: instant run 1", "test2: instant run 2" }
                },
                { choice = 1, inputs = { "hello" }, outputs = {} },
                { choice = 2, inputs = {}, outputs = { "integer=2,addr=-1:1111111111111111111111111111111111111111111111111111111111111111,string=hello" } },
                { choice = 3, inputs = {}, outputs = { "Debot Tests" } },
                { choice = 8, inputs = {}, outputs = {} }
            }

            check(steps)
        end)

        it("debot.run_method", function()
            local steps = {
                { choice = 4, inputs = {}, outputs = { "Test Run Method Action" } },
                { choice = 1, inputs = {}, outputs = {} },
                { choice = 2, inputs = {}, outputs = { "data=64" } },
                { choice = 3, inputs = {}, outputs = { "Debot Tests" } },
                { choice = 8, inputs = {}, outputs = {} }
            }

            check(steps)
        end)

        it("debot.send_msg", function()
            local steps = {
                { choice = 5, inputs = {}, outputs = { "Test Send Msg Action" } },
                { choice = 1, inputs = {}, outputs = { "Sending message [0-9a-f]+", "Transaction succeeded." } },
                { choice = 2, inputs = {}, outputs = {} },
                { choice = 3, inputs = {}, outputs = { "data=100" } },
                { choice = 4, inputs = {}, outputs = { "Debot Tests" } },
                { choice = 8, inputs = {}, outputs = {} }
            }

            check(steps)
        end)

        it("debot.invoke_debot", function()
            local steps = {
                { choice = 6, inputs = { debot_addr }, outputs = { "Test Invoke Debot Action", "enter debot address:" } },
                {
                    choice = 1,
                    inputs = {},
                    outputs = {},
                    invokes = {
                        { { choice = 1, inputs = {}, outputs = { "Print test string", "Debot is invoked" } } }
                    }
                },
                { choice = 2, inputs = {}, outputs = { "Debot Tests" } },
                { choice = 8, inputs = {}, outputs = {} }
            }

            check(steps)
        end)
    end)
end)

