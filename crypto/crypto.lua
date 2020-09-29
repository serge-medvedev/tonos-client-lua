local tc = require "tonclua"
local json = require "json"

local crypto = {}

function crypto.mnemonic_derive_sign_keys(ctx, phrase, path, dictionary, word_count)
    local params_json = json.encode(
        { phrase = phrase, path = path, dictionary = dictionary, word_count = word_count })
    local response_handle = tc.json_request(ctx, "crypto.mnemonic_derive_sign_keys", params_json)
    local err, result = tc.read_json_response(response_handle)

    if err then
        error(err)
    end

    return json.decode(result)
end

return crypto

