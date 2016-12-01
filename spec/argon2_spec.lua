local argon2 = require "argon2"

describe("argon2", function()
  it("_VERSION field", function()
    assert.equal("2.0.0", argon2._VERSION)
  end)
  it("_AUTHOR field", function()
    assert.equal("Thibault Charbonnier", argon2._AUTHOR)
  end)
  it("_LICENSE field", function()
    assert.equal("MIT", argon2._LICENSE)
  end)
  it("_URL field", function()
    assert.equal("https://github.com/thibaultcha/lua-argon2", argon2._URL)
  end)
  it("variants field", function()
    assert.is_table(argon2.variants)
    assert.is_userdata(argon2.variants.argon2_i)
    assert.is_userdata(argon2.variants.argon2_d)
    assert.is_userdata(argon2.variants.argon2_id)
  end)
end)

describe("encrypt()", function()
  it("should throw error on invalid argument", function()
    assert.has_error(function()
      argon2.encrypt(nil)
    end, "bad argument #1 to 'encrypt' (string expected, got nil)")

    assert.has_error(function()
      argon2.encrypt("", nil)
    end, "bad argument #2 to 'encrypt' (string expected, got nil)")

    assert.has_error(function()
      argon2.encrypt("", "", "")
    end, "bad argument #3 to 'encrypt' (expected to be a table)")

    assert.has_error(function()
      argon2.encrypt("", "", {t_cost = ""})
    end, "bad argument #3 to 'encrypt' (expected t_cost to be a number, got string)")

    assert.has_error(function()
      argon2.encrypt("", "", {m_cost = ""})
    end, "bad argument #3 to 'encrypt' (expected m_cost to be a number, got string)")

    assert.has_error(function()
      argon2.encrypt("", "", {parallelism = ""})
    end, "bad argument #3 to 'encrypt' (expected parallelism to be a number, got string)")

    assert.has_error(function()
      argon2.encrypt("", "", {}, "")
    end, "expecting no more than 3 arguments, but got 4")

    assert.has_error(function()
      argon2.encrypt("", "", { variant = "" })
    end, "bad argument #3 to 'encrypt' (expected variant to be a number, got string)")
  end)
  it("salt too short", function()
    local encoded, err = argon2.encrypt("password", "")
    assert.falsy(encoded)
    assert.equal("Salt is too short", err)

    encoded, err = argon2.encrypt("password", "abcdefg")
    assert.falsy(encoded)
    assert.equal("Salt is too short", err)
  end)
  it("should return a encoded", function()
    local encoded = assert(argon2.encrypt("password", "somesalt"))
    assert.matches("$argon2i$v=19$m=12,t=2,p=1$", encoded, nil, true)
  end)
  it("should encode with argon2d", function()
    local encoded = assert(argon2.encrypt("password", "somesalt", {
      variant = argon2.variants.argon2_d
    }))
    assert.matches("argon2d", encoded)
  end)
  it("should encode with argon2_id", function()
    local encoded = assert(argon2.encrypt("password", "somesalt", {
      variant = argon2.variants.argon2_id
    }))
    assert.matches("argon2id", encoded)
  end)
  it("should accept time cost", function()
    local encoded = assert(argon2.encrypt("password", "somesalt", {
      t_cost = 4
    }))
    assert.matches("t=4", encoded)
  end)
  it("should accept memory cost", function()
    local encoded = assert(argon2.encrypt("password", "somesalt", {
      m_cost = 13
    }))
    assert.matches("m=13", encoded)
  end)
  it("should accept parallelism", function()
    local encoded = assert(argon2.encrypt("password", "somesalt", {
      parallelism = 2,
      m_cost = 24
    }))
    assert.matches("p=2", encoded)
  end)
  it("should accept hash_len", function()
    local encoded_hash_default = assert(argon2.encrypt("password", "somesalt"))
    assert.is_string(encoded_hash_default)

    local encoded_hash_64 = assert(argon2.encrypt("password", "somesalt", {
      hash_len = 64
    }))
    assert.is_string(encoded_hash_64)

    assert.not_equal(encoded_hash_default, encoded_hash_64)
  end)
  it("should accept several options at once", function()
    local encoded = assert(argon2.encrypt("password", "somesalt", {
      t_cost = 4,
      m_cost = 24,
      parallelism = 2
    }))
    assert.matches("m=24,t=4,p=2", encoded)
  end)
  it("should calculate the appropriate encoded_len (triggered by long salt)", function()
    local encoded = assert(argon2.encrypt("password", string.rep("salt", 8)))
    assert.matches("$argon2i$v=19$m=12,t=2,p=1$", encoded, nil, true)
  end)
end)

describe("verify()", function()
  it("should throw error on invalid argument", function()
    assert.has_error(function()
      argon2.verify(nil)
    end, "expecting 2 arguments, but got 1")

    assert.has_error(function()
      argon2.verify(nil, nil)
    end, "bad argument #1 to 'verify' (string expected, got nil)")

    assert.has_error(function()
      argon2.verify("", nil)
    end, "bad argument #2 to 'verify' (string expected, got nil)")

    assert.has_error(function()
      argon2.verify("", "", "")
    end, "expecting 2 arguments, but got 3")
  end)
  it("should verify ok", function()
    local encoded = assert(argon2.encrypt("password", "somesalt"))
    assert(argon2.verify(encoded, "password"))
  end)
  it("should return false and no error on password mismatch", function()
    local encoded = assert(argon2.encrypt("password", "somesalt"))
    local ok, err = argon2.verify(encoded, "passworld")
    assert.False(ok)
    assert.is_nil(err)
  end)
  it("should verify argon2d ok", function()
    local encoded = assert(argon2.encrypt("password", "somesalt", {
      variant = argon2.variants.argon2_d
    }))
    assert(argon2.verify(encoded, "password"))
  end)
  it("should verify argon2d fail", function()
    local encoded = assert(argon2.encrypt("password", "somesalt", {
      variant = argon2.variants.argon2_d
    }))
    local ok, err = argon2.verify(encoded, "passworld")
    assert.False(ok)
    assert.is_nil(err)
  end)
  it("should verify argon2id ok", function()
    local encoded = assert(argon2.encrypt("password", "somesalt", {
      variant = argon2.variants.argon2_id
    }))
    assert(argon2.verify(encoded, "password"))
  end)
  it("should verify argon2id fail", function()
    local encoded = assert(argon2.encrypt("password", "somesalt", {
      variant = argon2.variants.argon2_id
    }))
    local ok, err = argon2.verify(encoded, "passworld")
    assert.False(ok)
    assert.is_nil(err)
  end)
  it("should return nil and an error message on failure to decode", function()
    local encoded = "$argon2i$v=19$m=4096,t=3,p=1c29tZXNhbHQ$iWh06vD8Fy27wf9npn6FXWiCX4K6pW6Ue1Bnzz07Z8A"
    local ok, err = argon2.verify(encoded, "")
    assert.is_nil(ok)
    assert.equal("Decoding failed", err)
  end)
end)

describe("module settings", function()
  it("should throw error on invalid argument", function()
    assert.has_error(function()
      argon2.t_cost(0, 0)
    end, "expecting no more than 1 arguments, but got 2")

    assert.has_error(function()
      argon2.t_cost ""
    end, "bad argument #1 to 't_cost' (expected t_cost to be a number, got string)")

    assert.has_error(function()
      argon2.variant(nil)
    end, "bad argument #1 to 'variant' (userdata expected, got nil)")
  end)
  it("should accept t_cost module setting", function()
    finally(function()
      argon2.t_cost(2)
    end)

    assert.equal(4, argon2.t_cost(4))

    local encoded = assert(argon2.encrypt("password", "somesalt"))
    assert.matches("$argon2i$v=19$m=12,t=4,p=1$", encoded, nil, true)

    encoded = assert(argon2.encrypt("password", "somesalt", {
      t_cost = 2
    }))
    assert.matches("$argon2i$v=19$m=12,t=2,p=1$", encoded, nil, true)
  end)
  it("should accept m_cost module setting", function()
    finally(function()
      argon2.m_cost(12)
    end)

    assert.equal(24, argon2.m_cost(24))

    local encoded = assert(argon2.encrypt("password", "somesalt"))
    assert.matches("$argon2i$v=19$m=24,t=2,p=1$", encoded, nil, true)

    encoded = assert(argon2.encrypt("password", "somesalt", {
      m_cost = 12
    }))
    assert.matches("$argon2i$v=19$m=12,t=2,p=1$", encoded, nil, true)
  end)
  it("should accept parallelism module setting", function()
    finally(function()
      argon2.parallelism(1)
    end)

    assert.equal(2, argon2.parallelism(2))

    local encoded = assert(argon2.encrypt("password", "somesalt", {
      m_cost = 24
    }))
    assert.matches("$argon2i$v=19$m=24,t=2,p=2$", encoded, nil, true)

    encoded = assert(argon2.encrypt("password", "somesalt", {
      parallelism = 1
    }))
    assert.matches("$argon2i$v=19$m=12,t=2,p=1$", encoded, nil, true)
  end)
  it("should accept hash_len module setting", function()
    finally(function()
      argon2.hash_len(32)
    end)

    local encoded_default_hash_len = assert(argon2.encrypt("password", "somesalt"))

    assert.equal(64, argon2.hash_len(64))

    local encoded_hash_len_64 = assert(argon2.encrypt("password", "somesalt"))

    assert.not_equal(encoded_default_hash_len, encoded_hash_len_64)
  end)
  it("should accept variant module setting", function()
    finally(function()
      argon2.variant(argon2.variants.argon2_i)
    end)

    local variant = argon2.variant(argon2.variants.argon2_d)
    assert.equal(argon2.variants.argon2_d, variant)

    local encoded = assert(argon2.encrypt("password", "somesalt"))
    assert.matches("$argon2d$v=19$m=12,t=2,p=1$", encoded, nil, true)

    encoded = assert(argon2.encrypt("password", "somesalt", {
      variant = argon2.variants.argon2_i
    }))
    assert.matches("$argon2i$v=19$m=12,t=2,p=1$", encoded, nil, true)
  end)
end)

