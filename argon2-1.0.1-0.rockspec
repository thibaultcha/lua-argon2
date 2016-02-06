package = "argon2"
version = "1.0.1-0"
source = {
  url = "git://github.com/thibaultCha/lua-argon2",
  tag = "1.0.1"
}
description = {
  summary = "A binding for password hash Argon2, winner of PHC",
  homepage = "https://github.com/P-H-C/phc-winner-argon2",
  license = "MIT"
}
build = {
  type = "builtin",
  modules = {
    argon2 = "src/argon2.lua",
    largon2 = {
      sources = {"src/largon2.c"},
      libraries = {"argon2"},
      incdirs = {"$(ARGON2_INCDIR)"},
      libdirs = {"$(ARGON2_LIBDIR)"}
    }
  }
}
