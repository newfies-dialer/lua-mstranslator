package = "mstranslator"
version = "0.1.0-1"
source = {
  url = "https://github.com/newfies-dialer/lua-mstranslator/archive/v0.1.0.tar.gz",
  dir = "mstranslator-0.1.0-1"
}
description = {
  summary = "Lua MSTranslator",
  detailed = [[
    Microsoft Translator API Helper for Lua
  ]],
  homepage = "https://github.com/newfies-dialer/lua-mstranslator/",
  license = "MIT <http://opensource.org/licenses/MIT>"
}
dependencies = {
  "lua >= 5.1"
}
build = {
  type = "builtin",
   modules = {
    mstranslator = "src/mstranslator.lua"
  }
}