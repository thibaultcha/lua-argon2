package = "argon2"
version = "1.0-0"
source = {
  url = "https://github.com/thibaultCha/lua-argon2",
  tag = "1.0-0"
}
description = {
  summary = "The password hash Argon2, winner of PHC",
  homepage = "https://github.com/P-H-C/phc-winner-argon2",
  license = "CC0"
}
build = {
  type = "make",
  build_variables = {
    CFLAGS="$(CFLAGS)",
    LIBFLAG="$(LIBFLAG)",
    LUA_LIBDIR="$(LUA_LIBDIR)",
    LUA_INCDIR="$(LUA_INCDIR)"
  },
  install_variables = {
    INST_LIBDIR = "$(LIBDIR)",
    INST_LUADIR = "$(LUADIR)"
  }
}
