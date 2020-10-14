rockspec_format = "3.0"
package = "ton-client"
version = "scm-1"
source = {
    url = "git://github.com:serge-medvedev/ton-client-lua.git",
    tag = "1.0.0-rc"
}
description = {
    summary = "Lua bindings to TON SDK's Core Client Library",
    license = "MIT",
    labels = { "ton", "freeton" }
}
dependencies = {
    "lua >= 5.1",
    "dkjson >= 2.5"
}
build = {
    type = "builtin",
    modules = {
        ["ton.abi"] = "lib/ton/abi.lua",
        ["ton.boc"] = "lib/ton/boc.lua",
        ["ton.client"] = "lib/ton/client.lua",
        ["ton.crypto"] = "lib/ton/crypto.lua",
        ["ton.net"] = "lib/ton/net.lua",
        ["ton.processing"] = "lib/ton/processing.lua",
        ["ton.utils"] = "lib/ton/utils.lua",

        ["ton.context"] = "lib/ton/context.lua",

        ["ton.commons.async"] = "lib/ton/commons/async.lua",

        tonclua = {
            sources = { "src/tonclua/tonclua.c" },
            incdirs = { "src/tonclua/include" },
            libraries = { "ton_client" }
        }
    }
}

