local argon2 = require "argon2"

argon2.t_cost(8) -- change default setting

local hash = assert(argon2.encrypt("password", "somesalt"))
-- hash: argon2i hash

assert(argon2.verify(hash, "passworld")) -- error: The password did not match


------------------


local hash = assert(argon2.encrypt("password", "somesalt", {
  t_cost = 4, -- override default t_cost here
  m_cost = 24, -- override other default settings
  parallelism = 4,
  argon2d = true -- use Argon2d hashing for this operation only
}))
-- hash: argon2d hash

assert(argon2.verify(hash, "password")) -- ok


------------------


argon2.argon2d(true) -- use Argon2d hashing by default from now on

-- ...
