## [Unreleased][unreleased]

## [3.0.0]

### Changed

- :warning: This version is only compatible with Argon2
  [20160406](https://github.com/P-H-C/phc-winner-argon2/releases/tag/20160406)
  and later.
- :warning: Renamed the `encrypt()` function to `hash_encoded()`, in order to
  carry a stronger meaning and to eventually implement a `hash_raw()` function
  in the future.
- New `variants` field with supported Argon2 encoding variants (as userdatum).
  See documentation and the "Added" section of this Changelog.
- Updated the default hashing options to match those of the Argon2 CLI:
  `t_cost = 3`, `m_cost = 4096`, `parallelism = 1`, `hash_len = 32`.

### Added

- :stars: Support for Argon2id encoding variant.
  [#24](https://github.com/thibaultcha/lua-argon2/pull/24)
- We now automatically compute the length of the retrieved encoded hash from
  `encrypt()`. [#21](https://github.com/thibaultcha/lua-argon2/pull/21)
- New option: `hash_len`.
  [#22](https://github.com/thibaultcha/lua-argon2/pull/22)
- Return errors from `verify()`. A mismatch now returns `false, nil`, while an
  error will return `nil, "err string"`.
  [#23](https://github.com/thibaultcha/lua-argon2/pull/23)
- ANSI C compatibility.
  [#27](https://github.com/thibaultcha/lua-argon2/pull/27)

## [2.0.0] - 2016/04/07

### Added

- :stars: Support for Argon2
  [20160406](https://github.com/P-H-C/phc-winner-argon2/releases/tag/20160406)
  (and later). The major version of this module has been bumped because the
  resulting hashes will not be backwards compatible.
  [885f48](https://github.com/thibaultcha/lua-argon2/commit/885f488257dfcaa0acaa47da7b6fa709f2840bc7)

## [1.2.0] - 2016/02/26

### Added

- Allow configuration of this module's defaults.
  [#15](https://github.com/thibaultcha/lua-argon2/pull/15)

### Fixed

- `verify()` was wrongfully accepting 3 arguments. Only 2 arguments are now
  accepted. [d2c6091](https://github.com/thibaultcha/lua-argon2/commit/d2c60918797896437b35986dc3e9366327a74418)

## [1.1.1] - 2016/02/06

### Fixed

- Correct error message for invalid option argument to `encrypt()`.
  [#14](https://github.com/thibaultcha/lua-argon2/pull/14)

## [1.1.0] - 2016/02/06

### Changed

- Removed the Lua module. This binding now entirely consists of a C binding.
  [#13](https://github.com/thibaultcha/lua-argon2/pull/13)

## [1.0.1] - 2016/02/05

### Fixed

- Fix the path to the C bridge in Luarocks install.
  [#12](https://github.com/thibaultcha/lua-argon2/pull/12)

### Added

- Published a documentation.
  [#10](https://github.com/thibaultcha/lua-argon2/pull/10)
- Implement tests coverage.
  [#7](https://github.com/thibaultcha/lua-argon2/pull/7)

## [1.0.0] - 2016/01/16

Initial release with support for Argon2
[20151206](https://github.com/P-H-C/phc-winner-argon2/releases/tag/20151206).
Implement a C bridge for Argon2i and Argon2d encoding and a
Lua module for input validation.

[unreleased]: https://github.com/thibaultcha/lua-argon2/compare/3.0.0...master
[3.0.0]: https://github.com/thibaultcha/lua-argon2/compare/2.0.0...3.0.0
[2.0.0]: https://github.com/thibaultcha/lua-argon2/compare/1.2.0...2.0.0
[1.2.0]: https://github.com/thibaultcha/lua-argon2/compare/1.1.1...1.2.0
[1.1.1]: https://github.com/thibaultcha/lua-argon2/compare/1.1.0...1.1.1
[1.1.0]: https://github.com/thibaultcha/lua-argon2/compare/1.0.1...1.1.0
[1.0.1]: https://github.com/thibaultcha/lua-argon2/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/thibaultcha/lua-argon2/compare/400523adde75084200095373e413c8563beb2a04...1.0.0
