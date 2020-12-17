rockspec_format = "3.0"
package = "tonos-client"
version = "scm-1"
source = {
    url = "file:///usr/src/tonos-client.zip"
}
description = {
    summary = "Lua bindings to TON OS SDK's Core Client Library",
    license = "MIT",
    labels = { "ton", "tonos" }
}
dependencies = {
    "lua ~> 5.1",
    "dkjson >= 2.5"
}
test_dependencies = {
    "busted",
    "lumen"
}
test = {
    type = "busted",
    flags = { "--run", "free" }
}
build = {
    type = "builtin",
    modules = {
        ["tonos.client"] = "build/generated/client.lua",
        tonosclua = {
            sources = { "src/tonosclua/tonosclua.c" },
            defines = { "NDEBUG" },
            incdirs = { "src/tonosclua/include" },
            libraries = { "ton_client" }
        }
    }
}

