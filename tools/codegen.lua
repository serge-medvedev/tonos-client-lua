#!/usr/bin/env lua

local json = require("dkjson")
local lustache = require("lustache")
local function load_api_description(path)
    local file = io.open(path, "r")

    if not file then
        error("failed to open " .. path)
    end

    local contents = file:read("*a")

    io.close(file)

    local decoded = json.decode(contents)

    if decoded == nil then
        error("failed to decode file contents")
    end

    return decoded
end

local function save_code(code)
    local target = {
        dir = "build/generated",
        file = "client.lua"
    }

    os.execute("mkdir -p " .. target.dir)

    local file = io.open(target.dir .. "/" .. target.file, "w+")

    file:write(code)
end

local api = load_api_description(arg[1])

for _, m in pairs(api.modules) do
    m["module_name"] = m["name"]
    m["name"] = nil

    for _, f in pairs(m["functions"]) do
        f["function_name"] = f["name"]
        f["name"] = nil
    end
end

api.modules[#api.modules].last = true

local template = [[
local tc = require "tonclua"
local json = require "dkjson"

local function async_iterator_factory(ctx, method, params_json)
    local request_id = tc.request(ctx, method, json.encode(params_json) or "")
    local meta = {
        __call = coroutine.wrap(function()
            local id

            while request_id ~= id do
                id = tc.fetch_response_data(request_id) -- yields on the C-side, returns request_id when finished
            end
        end)
    }
    local iterator_factory = setmetatable({}, meta)

    function iterator_factory.await()
        for request_id, params_json, response_type, finished in iterator_factory do
            if finished then
                return json.decode(params_json)
            end
        end
    end

    return iterator_factory
end

---------- context: methods for context creation/destroying

local context = {}

function context.create(config)
    local response_handle = tc.create_context(config)
    local result = tc.read_string(response_handle)
    local decoded = json.decode(result)

    if decoded == nil then
        error("response is empty")
    elseif decoded.error then
        error(decoded.error)
    end

    return decoded.result
end

function context.destroy(handle)
    tc.destroy_context(handle)
end

{{#modules}}
---------- {{module_name}}:{{summary}}

local {{module_name}} = {}

{{#functions}}
function {{module_name}}.{{function_name}}(ctx, params_json)
    return async_iterator_factory(ctx, "{{module_name}}.{{function_name}}", params_json)
end

{{/functions}}
{{/modules}}
return {
    context = context,
    {{#modules}}
    {{module_name}} = {{module_name}}{{^last}},{{/last}}
    {{/modules}}
}

]]
local code = lustache:render(template, api)

save_code(code)

