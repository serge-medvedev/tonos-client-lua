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
build_dependencies = {
    "busted"
}
test = {
    type = "busted",
    flags = { "--run", "free" }
}
build = {
    type = "builtin",
    modules = {
        ["ton.client"] = "build/generated/client.lua",
        tonclua = {
            sources = { "src/tonclua/tonclua.c" },
            incdirs = { "src/tonclua/include" },
            libraries = { "ton_client" }
        }
    }
}

