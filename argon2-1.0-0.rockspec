package = "argon2"
version = "1.0-0"
source = {
  url = "git://github.com/thibaultCha/lua-argon2",
  tag = "1.0-0"
}
description = {
  summary = "A binding for password hash Argon2, winner of PHC",
  homepage = "https://github.com/P-H-C/phc-winner-argon2",
  license = "MIT"
}
build = {
  type = "make",
  build_variables = {
    LUA_CFLAGS="$(CFLAGS)",
    LIBFLAG="$(LIBFLAG)",
    LUA_INCDIR="-I$(LUA_INCDIR)",
    LUA_LIBDIR="-L$(LUA_LIBDIR)"
  },
  install_variables = {
    INST_LIBDIR = "$(LIBDIR)",
    INST_LUADIR = "$(LUADIR)"
  }
}
