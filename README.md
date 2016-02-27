# lua-argon2 [![Module Version][badge-version-image]][luarocks-argon2] [![Build Status][badge-travis-image]][badge-travis-url] [![Coverage Status][badge-coveralls-image]][badge-coveralls-url]

Lua binding for [Argon2]. Compatible with Lua 5.x and LuaJIT.

> For LuaJIT or [ngx_lua]/[OpenResty] usage, consider [lua-argon2-ffi](https://github.com/thibaultCha/lua-argon2-ffi).

### Prerequisites

The [Argon2] shared library must be compiled and available in your system.

### Install

This binding can be installed with [Luarocks](https://luarocks.org):

```
$ luarocks install argon2 ARGON2_INCDIR="..." ARGON2_LIBDIR="..."
```

`ARGON2_INCDIR` must contain the `argon2.h` header file, and `ARGON2_LIBDIR` must contain the compiled shared library for your platform.

Or by using the Makefile (use the provided variables to point it to your Lua and argon2 installations):

```
$ make
```

Using the Makefile will compile `argon2.so` which must be placed somewhere in your `LUA_CPATH`.

### Usage

Encrypt:

```lua
local argon2 = require "argon2"

-- Argon2i
local hash, err = argon2.encrypt("password", "somesalt")
assert(err == nil)
assert(hash == "$argon2i$m=12,t=2,p=1$c29tZXNhbHQ$ltrjNRFqTXmsHj++TFGZxg+zSg8hSrrSJiViCRns1HM")

-- Argon2d
local hash, err = argon2.encrypt("password", "somesalt", {argon2d = true})
assert(err == nil)
assert(hash == "$argon2d$m=12,t=2,p=1$c29tZXNhbHQ$mfklun4fYCbv2Hw0UnZZ56xAqWbjD+XRMSN9h6SfLe4")

-- Options
local hash, err = argon2.encrypt("password", "somesalt", {
  t_cost = 4,
  m_cost = 24,
  parallelism = 2
})
assert(err == nil)
assert(hash == "$argon2i$m=24,t=4,p=2$c29tZXNhbHQ$8BtAMKSLKR3l66c3l40LKrg09NwLD7hJYfSqoLQyKEE")

-- Default options
argon2.t_cost(4)
argon2.m_cost(24)
argon2.parallelism(24)
argon2.argon2d(true)
```

Verify:

```lua
local argon2 = require "argon2"

local hash, err = argon2.encrypt("password", "somesalt")
assert(err == nil)

local ok, err = argon2.verify(hash, "password")
assert(err == nil)
assert(ok == true)

local ok, err = argon2.verify(hash, "passworld")
assert(err == "The password did not match.")
assert(ok == false)
```

### Documentation

The full documentation is available [online](http://thibaultcha.github.io/lua-argon2/).

### License

Work licensed under the MIT License. Please check [P-H-C/phc-winner-argon2][Argon2] for license over Argon2 and the reference implementation.

[Argon2]: https://github.com/P-H-C/phc-winner-argon2
[luarocks-argon2]: http://luarocks.org/modules/thibaultcha/argon2

[ngx_lua]: https://github.com/openresty/lua-nginx-module
[OpenResty]: https://openresty.org

[badge-travis-url]: https://travis-ci.org/thibaultCha/lua-argon2
[badge-travis-image]: https://travis-ci.org/thibaultCha/lua-argon2.svg?branch=master
[badge-version-image]: https://img.shields.io/badge/version-1.1.1-blue.svg?style=flat
[badge-coveralls-url]: https://coveralls.io/github/thibaultCha/lua-argon2?branch=master
[badge-coveralls-image]: https://coveralls.io/repos/github/thibaultCha/lua-argon2/badge.svg?branch=master
