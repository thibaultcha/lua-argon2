#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <argon2.h>

#if LUA_VERSION_NUM < 502
# define luaL_newlib(L,l) (lua_newtable(L), luaL_register(L,NULL,l))
# define lua_rawlen lua_objlen
#endif

const uint32_t ENCODED_LEN = 108u;
const uint32_t HASH_LEN = 32u;
const uint32_t SALT_LEN = 16u;

static const char *const type_opts[] = {"d", "i", NULL};
static const enum Argon2_type types[] = {Argon2_d, Argon2_i};

static int hash(lua_State *L) {
  lua_settop(L, 6);

  const char *plain, *salt;
  size_t plainlen, saltlen;

  char encoded[ENCODED_LEN];

  uint32_t t_cost = luaL_checknumber(L, 1); // time cost: 3
  uint32_t m_cost = luaL_checknumber(L, 2); // memory cost: 12
  uint32_t parallelism = luaL_checknumber(L, 3); // parallelism: 1

  plain = luaL_checklstring(L, 4, &plainlen); // plain
  salt = luaL_checklstring(L, 5, &saltlen); // salt

  uint8_t o = luaL_checkoption(L, 6, "d", type_opts);
  argon2_type type = types[o];

  argon2_error_codes result = argon2_hash(t_cost, m_cost, parallelism, plain,
            plainlen, salt, saltlen, NULL, HASH_LEN,
            encoded, ENCODED_LEN, type);
  if (result != ARGON2_OK) {
    const char *err_msg = error_message(result);
    lua_pushnil(L);
    lua_pushstring(L, err_msg);
    return 2;
  }

  lua_pushstring(L, encoded);
  return 1;
}

static const luaL_Reg argon2[] = {
  {"hash", hash},
  {NULL, NULL}
 };

int luaopen_argon2(lua_State *L) {
  luaL_newlib(L, argon2);
  return 1;
}
