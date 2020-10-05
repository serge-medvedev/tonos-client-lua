package = "ton-client"
version = "scm-0"
source = {
  url = "git://github.com:serge-medvedev/ton-client-lua.git",
  branch = "master"
}
description = {
  summary = "Lua binding for TON SDK",
  license = "MIT"
}
dependencies = {
  "lua >= 5.1"
}
build = {
  type = "builtin",
  modules = {
      ["tonclua"] = {
          sources = { "tonclua.c" },
          libraries = { "ton_client" },
          libdirs = { "/usr/lib" }
      }
  }
}

