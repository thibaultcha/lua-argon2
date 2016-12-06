package = "argon2"
version = "3.0.0-1"
source = {
  url = "git://github.com/thibaultcha/lua-argon2",
  tag = "3.0.0"
}
description = {
  summary = "Lua C binding for the Argon2 password hashing function",
  homepage = "https://github.com/thibaultcha/lua-argon2",
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
