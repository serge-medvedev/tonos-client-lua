package = "ton-client"
version = "scm-0"
source = {
  url = "git://github.com/..."
}
description = {
  summary = "TON Client for Lua",
  detailed = [[ ... ]],
  license = "MIT",
  homepage = "http://github.com/..."
}
dependencies = {
  "lua >= 5.1"
}
build = {
  type = "make",
  build_target = "tonclua.so",
  intall_target = ""
}

