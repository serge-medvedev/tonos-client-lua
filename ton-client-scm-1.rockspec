package = "ton-client"
version = "scm-1"
source = {
  url = "git://github.com/..."
}
description = {
  summary = "TON Client for Lua",
  detailed = [[ ... ]],
  license = "Apache-2.0",
  homepage = "http://github.com/..."
}
dependencies = {
  "lua >= 5.1"
}
build = {
  type = "make",
  build_target = "tc_lua_wrapper.so",
  intall_target = ""
}

