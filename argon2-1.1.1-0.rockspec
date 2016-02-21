package = "argon2"
version = "1.1.1-0"
source = {
  url = "git://github.com/thibaultCha/lua-argon2",
  tag = "1.1.1"
}
description = {
  summary = "Pure Lua binding for the Argon2 password hashing algorithm",
  homepage = "https://github.com/thibaultCha/lua-argon2",
  license = "MIT"
}
build = {
  type = "builtin",
  modules = {
    argon2 = {
      sources = {"src/argon2.c"},
      libraries = {"argon2"},
      incdirs = {"$(ARGON2_INCDIR)"},
      libdirs = {"$(ARGON2_LIBDIR)"}
    }
  }
}
