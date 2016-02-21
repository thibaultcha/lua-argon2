local argon2 = require "argon2"

local hash, err = argon2.encrypt("password", "somesalt", {
  t_cost = 4,
  m_cost = 24,
  parallelism = 4
})
if not hash then
  error(err)
end

local ok, err = argon2.verify(hash, "passworld")
if not ok then
  error(err) -- The password did not match
end

local ok, err = argon2.verify(hash, "password")
assert(ok)
