local libargon2 = require "largon2"
local match = string.match
local error = error
local type = type

local opts = {
  timeCost = 2,
  memoryCost = 12,
  parallelism = 1,
  argon2d = false
}

local _M = {}

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

function _M.verify(encrypted, plain)
  local m = match(encrypted, "argon2d")
  return libargon2.verify(encrypted, plain, m ~= nil and "d" or "i")
end

return _M
