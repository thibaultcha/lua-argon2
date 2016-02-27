local argon2 = require "argon2"

argon2.t_cost(8) -- change default setting

local hash, err = argon2.encrypt("password", "somesalt")
if not hash then
  error(err)
end

local ok, err = argon2.verify(hash, "passworld")
if not ok then
  error(err) -- The password did not match
end


------------------


local hash, err = argon2.encrypt("password", "somesalt", {
  t_cost = 4, -- override default t_cost here
  m_cost = 24, -- override other default settings
  parallelism = 4,
  argon2d = true -- use Argon2d hashing
})
if not hash then
  error(err)
end

local ok, err = argon2.verify(hash, "password")
assert(ok)


------------------


argon2.argon2d(true) -- use Argon2d hashing by default from now on

-- ...
