local async = require "ton.commons.async"

local tvm = {}

function tvm.execute_message(ctx, message, account, mode, execution_options)
    local params_json = {
        message = message,
        account = account,
        mode = mode,
        execution_options = execution_options
    }

    return async.iterator_factory(ctx, "tvm.execute_message", params_json)
end

function tvm.execute_get(ctx, account, function_name, input, execution_options)
    local params_json = {
        account = account,
        function_name = function_name,
        input = input,
        execution_options = execution_options
    }

    return async.iterator_factory(ctx, "tvm.execute_get", params_json).pick("output")
end

return tvm

