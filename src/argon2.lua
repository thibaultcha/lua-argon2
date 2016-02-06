--- Lua Argon2
-- Lua binding for the Argon2 password hashing function.
--
-- See the [Argon2 documentation](https://github.com/P-H-C/phc-winner-argon2) at the same time while you consult this binding's documentation.
--
-- @module argon2
-- @author thibaultcha
-- @release 1.0.0

local libargon2 = require "largon2"
local match = string.match
local error = error
local type = type

--- Hashing options.
-- When using `encrypt`, the third argument is a table describing the Argon2
-- options to use.
-- @field timeCost Number of iterations (`number`)
--     type: number
--     default: 2
-- @field memoryCost Sets memory usage to m_cost kibibytes (`number`)
--     type: number
--     default: 12
-- @field parallelism Number of threads and compute lanes (`number`)
--     type: number
--     default: 1
-- @field argon2d If `true`, will use argon2d hashing (`boolean`)
--     type: boolean
--     default: false
-- @table options
local opts = {
  timeCost = 2,
  memoryCost = 12,
  parallelism = 1,
  argon2d = false
}

local _M = {
  _VERSION = "1.0.1"
}

--- Encrypt a plain string.
-- Uses Argon2i (by default) or Argon2d to hash a password (or any plain string).
-- @param[type=string] pwd Password (or plain string) to hash.
-- @param[type=string] salt Salt to use to hash pwd. Must not exceed 16 characters.
-- @param[type=table] options Options with which to hash the plain string. See `options`.
-- @treturn string `hash`: Hash computed by Argon2 or nil if an error occurred.
-- @treturn string `error`: `nil` or a string describing the error if any.
function _M.encrypt(pwd, salt, options)
  if type(pwd) ~= "string" then
    error("pwd must be a string", 2)
  end

  if type(salt) ~= "string" then
    error("salt must be a string", 2)
  end

  if type(options) ~= "table" then
    options = opts
  else
    for k, v in pairs(opts) do
      if options[k] == nil then
        options[k] = v
      end
    end
    if options.timeCost ~= nil and type(options.timeCost) ~= "number" then
      error("Time cost must be a number", 2)
    end

    if options.memoryCost ~= nil and type(options.memoryCost) ~= "number" then
      error("Memory cost must be a number", 2)
    end

    if options.parallelism ~= nil and type(options.parallelism) ~= "number" then
      error("Parallelism must be a number", 2)
    end
  end

  return libargon2.hash(options.timeCost, options.memoryCost, options.parallelism,
                        pwd, salt, options.argon2d == true and "d" or "i")
end

--- Verify a plain string against a hash.
-- Uses Argon2i or Argon2d to verify if a given password (or any plain string)
-- verifies against a hash encrypted with Argon2.
-- @param[type=string] encrypted Hash to verify the plain string against.
-- @param[type=string] plain Plain string to verify.
-- @treturn boolean `ok`: `true` if the password matched, `false` otherwise.
-- @treturn string `error`: `nil` or a string describing the error if any.
function _M.verify(encrypted, plain)
  local m = match(encrypted, "argon2d")
  return libargon2.verify(encrypted, plain, m ~= nil and "d" or "i")
end

return _M
