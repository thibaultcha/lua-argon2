# lua-argon2

[![Module Version][badge-version-image]][luarocks-argon2]
[![Build Status][badge-travis-image]][badge-travis-url]
[![Coverage Status][badge-coveralls-image]][badge-coveralls-url]

Lua C binding for the [Argon2] password hashing function. Compatible with
Lua 5.x and LuaJIT.

> For LuaJIT or [ngx_lua]/[OpenResty] usage, consider the FFI implementation
> if this binding:
> [lua-argon2-ffi](https://github.com/thibaultcha/lua-argon2-ffi).

### Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Documentation](#documentation)
- [Example](#example)
- [License](#license)

### Requirements

The [Argon2] shared library must be compiled and available in your system.

Compatibility:
- Version `1.x` of this module is compatible with Argon2
  [`20151206`](https://github.com/P-H-C/phc-winner-argon2/releases/tag/20151206).
- Version `2.x` of this module is compatible with Argon2
  [`20160406`](https://github.com/P-H-C/phc-winner-argon2/releases/tag/20160406)
  to [`20161029`](https://github.com/P-H-C/phc-winner-argon2/releases/tag/20161029).
- Version `3.x` of this module is compatible with Argon2
  [`20161029`](https://github.com/P-H-C/phc-winner-argon2/releases/tag/20161029)
  and above.

See the [CI builds][badge-coveralls-url] for the status of the currently
supported versions.

[Back to TOC](#table-of-contents)

### Installation

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

[Back to TOC](#table-of-contents)

### Documentation

This binding's documentation is available at
<http://thibaultcha.github.io/lua-argon2/>.

The Argon2 password hashing function documentation is available at
<https://github.com/P-H-C/phc-winner-argon2>.

[Back to TOC](#table-of-contents)

### Example

Hash a password to an encoded string:

```lua
local argon2 = require "argon2"
--- Prototype
-- local encoded, err = argon2.hash_encoded(pwd, salt, opts)

--- Argon2i
local encoded = assert(argon2.hash_encoded("password", "somesalt"))
-- encoded is "$argon2i$v=19$m=4096,t=3,p=1$c29tZXNhbHQ$iWh06vD8Fy27wf9npn6FXWiCX4K6pW6Ue1Bnzz07Z8A"

--- Argon2d
local encoded = assert(argon2.hash_encoded("password", "somesalt", {
  variant = argon2.variants.argon2_d
}))
-- encoded is "$argon2d$v=19$m=4096,t=3,p=1$c29tZXNhbHQ$2+JCoQtY/2x5F0VB9pEVP3xBNguWP1T25Ui0PtZuk8o"

--- Argon2id
local encoded = assert(argon2.hash_encoded("password", "somesalt", {
  variant = argon2.variants.argon2_id
}))
-- encoded is "$argon2id$v=19$m=4096,t=3,p=1$c29tZXNhbHQ$qLml5cbqFAO6YxVHhrSBHP0UWdxrIxkNcM8aMX3blzU"

-- Hashing options
local encoded = assert(argon2.hash_encoded("password", "somesalt", {
  t_cost = 4,
  m_cost = math.pow(2, 16), -- 65536 KiB
  parallelism = 2
}))
-- encoded is "$argon2i$v=19$m=65536,t=4,p=2$c29tZXNhbHQ$n6x5DKNWV8BOeKemQJRk7BU3hcaCVomtn9TCyEA0inM"

-- Changing the default options (those arguments are the current defaults)
argon2.t_cost(3)
argon2.m_cost(4096)
argon2.parallelism(1)
argon2.hash_len(32)
argon2.variant(argon2.variants.argon2_i)
```

Verify a password against an encoded string:

```lua
local argon2 = require "argon2"
--- Prototype
-- local ok, err = argon2.decrypt(hash, plain)

local encoded = assert(argon2.hash_encoded("password", "somesalt"))
-- encoded: argon2i encoded hash

local ok, err = argon2.verify(encoded, "password")
if err then
  error("could not verify: " .. err)
end

if not ok then
  error("The password does not match the supplied hash")
end
```

[Back to TOC](#table-of-contents)

### License

Work licensed under the MIT License. Please check
[P-H-C/phc-winner-argon2][Argon2] for the license over Argon2 and the reference
implementation.

[Back to TOC](#table-of-contents)

[Argon2]: https://github.com/P-H-C/phc-winner-argon2
[luarocks-argon2]: http://luarocks.org/modules/thibaultcha/argon2

[ngx_lua]: https://github.com/openresty/lua-nginx-module
[OpenResty]: https://openresty.org

[badge-travis-url]: https://travis-ci.org/thibaultcha/lua-argon2
[badge-travis-image]: https://travis-ci.org/thibaultcha/lua-argon2.svg?branch=master
[badge-version-image]: https://img.shields.io/badge/version-3.0.0-blue.svg?style=flat
[badge-coveralls-url]: https://coveralls.io/github/thibaultcha/lua-argon2?branch=master
[badge-coveralls-image]: https://coveralls.io/repos/github/thibaultcha/lua-argon2/badge.svg?branch=master
