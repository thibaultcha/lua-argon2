# lua-argon2

[![Module Version][badge-version-image]][luarocks-argon2]
[![Build Status][badge-travis-image]][badge-travis-url]
[![Coverage Status][badge-coveralls-image]][badge-coveralls-url]

Lua binding for [Argon2]. Compatible with Lua 5.x and LuaJIT.

> For LuaJIT or [ngx_lua]/[OpenResty] usage, consider the FFI implementation
> if this binding:
> [lua-argon2-ffi](https://github.com/thibaultcha/lua-argon2-ffi).

### Prerequisites

The [Argon2] shared library must be compiled and available in your system.

Compatibility:
- Version `1.x` of this module is compatible with Argon2
  [`20151206`](https://github.com/P-H-C/phc-winner-argon2/releases/tag/20151206)
- Version `2.x` of this module is compatible with Argon2
  [`20160406`](https://github.com/P-H-C/phc-winner-argon2/releases/tag/20160406)
  to [`20161029`](https://github.com/P-H-C/phc-winner-argon2/releases/tag/20161029)
- Version `3.x` of this module is compatible with Argon2
  [`20161029`](https://github.com/P-H-C/phc-winner-argon2/releases/tag/20161029)
  and later

See the [CI builds][badge-coveralls-url] for the status of the currently
supported versions.

### Install

This binding can be installed via [Luarocks](https://luarocks.org):

```
$ luarocks install argon2 ARGON2_INCDIR="..." ARGON2_LIBDIR="..."
```

`ARGON2_INCDIR` must contain the `argon2.h` header file, and `ARGON2_LIBDIR`
must contain the compiled shared library for your platform.

Or by using the Makefile (use the provided variables to point it to your Lua
and Argon2 installations):

```
$ make
```

Using the Makefile will compile `argon2.so` which must be placed somewhere in
your `LUA_CPATH`.

### Usage

Encrypt:

```lua
local argon2 = require "argon2"
--- Prototype
-- local encoded, err = argon2.encrypt(pwd, salt, opts)

--- Argon2i
local encoded = assert(argon2.encrypt("password", "somesalt"))
-- encoded is "$argon2i$m=12,t=2,p=1$c29tZXNhbHQ$ltrjNRFqTXmsHj++TFGZxg+zSg8hSrrSJiViCRns1HM"

--- Argon2d
local encoded = assert(argon2.encrypt("password", "somesalt", {
  variant = argon2.variants.argon2_d
}))
-- encoded is "$argon2d$m=12,t=2,p=1$c29tZXNhbHQ$mfklun4fYCbv2Hw0UnZZ56xAqWbjD+XRMSN9h6SfLe4"

--- Argon2id
local encoded = assert(argon2.encrypt("password", "somesalt", {
  variant = argon2.variants.argon2_id
}))
-- encoded is "$argon2id$v=19$m=12,t=2,p=1$c29tZXNhbHQ$fJLcV2WII/sn+PjBK/b9YZfZFTNzU+21hyVt7xUWHDU"

-- Hashing options
local encoded = assert(argon2.encrypt("password", "somesalt", {
  t_cost = 4,
  m_cost = 16,
  parallelism = 2
}))
-- encoded is "$argon2i$m=24,t=4,p=2$c29tZXNhbHQ$8BtAMKSLKR3l66c3l40LKrg09NwLD7hJYfSqoLQyKEE"

-- Changing the default options (those arguments are the current defaults)
argon2.t_cost(2)
argon2.m_cost(12)
argon2.parallelism(1)
argon2.variant(argon2.variants.argon2_i)
```

Verify:

```lua
local argon2 = require "argon2"
--- Prototype
-- local ok, err = argon2.decrypt(hash, plain)

local encoded = assert(argon2.encrypt("password", "somesalt"))
-- encoded: argon2i encoded hash

local ok, err = argon2.verify(encoded, "password")
if err then
  error("could not verify: " .. err)
end

if not ok then
  error("The password does not match the supplied hash")
end
```

### Documentation

The full documentation is available
[online](http://thibaultcha.github.io/lua-argon2/).

### License

Work licensed under the MIT License. Please check
[P-H-C/phc-winner-argon2][Argon2] for license over Argon2 and the reference
implementation.

[Argon2]: https://github.com/P-H-C/phc-winner-argon2
[luarocks-argon2]: http://luarocks.org/modules/thibaultcha/argon2

[ngx_lua]: https://github.com/openresty/lua-nginx-module
[OpenResty]: https://openresty.org

[badge-travis-url]: https://travis-ci.org/thibaultcha/lua-argon2
[badge-travis-image]: https://travis-ci.org/thibaultcha/lua-argon2.svg?branch=master
[badge-version-image]: https://img.shields.io/badge/version-3.0.0-blue.svg?style=flat
[badge-coveralls-url]: https://coveralls.io/github/thibaultcha/lua-argon2?branch=master
[badge-coveralls-image]: https://coveralls.io/repos/github/thibaultcha/lua-argon2/badge.svg?branch=master
