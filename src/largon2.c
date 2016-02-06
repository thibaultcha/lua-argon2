#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <argon2.h>

#if LUA_VERSION_NUM < 502
#define luaL_newlib(L, l) (lua_newtable(L), luaL_register(L, NULL, l))
#define lua_rawlen lua_objlen
#endif

const uint32_t ENCODED_LEN = 108u;
const uint32_t HASH_LEN = 32u;

static const char *const type_opts[] = {"d", "i", NULL};
static const enum Argon2_type types[] = {Argon2_d, Argon2_i};

static int hash(lua_State *L) {
    lua_settop(L, 6);

    char encoded[ENCODED_LEN];

    const char *plain, *salt;
    size_t plainlen, saltlen;
    uint8_t o;

    uint32_t t_cost = luaL_checknumber(L, 1);
    uint32_t m_cost = luaL_checknumber(L, 2);
    uint32_t parallelism = luaL_checknumber(L, 3);

    plain = luaL_checklstring(L, 4, &plainlen);
    salt = luaL_checklstring(L, 5, &saltlen);
    o = luaL_checkoption(L, 6, "i", type_opts);

    argon2_error_codes result =
        argon2_hash(t_cost, m_cost, parallelism, plain, plainlen, salt, saltlen,
                    NULL, HASH_LEN, encoded, ENCODED_LEN, types[o]);
    if (result != ARGON2_OK) {
        const char *err_msg = error_message(result);
        lua_pushnil(L);
        lua_pushstring(L, err_msg);
        return 2;
    }

    lua_pushstring(L, encoded);
    return 1;
}

static int verify(lua_State *L) {
    lua_settop(L, 3);

    const char *plain, *encoded;
    size_t plainlen;
    uint8_t o;

    encoded = luaL_checkstring(L, 1);
    plain = luaL_checklstring(L, 2, &plainlen);
    o = luaL_checkoption(L, 3, "i", type_opts);

    argon2_error_codes result =
        argon2_verify(encoded, plain, plainlen, types[o]);
    if (result != ARGON2_OK) {
        lua_pushboolean(L, 0);
        lua_pushliteral(L, "The password did not match.");
        return 2;
    }

    lua_pushboolean(L, 1);
    return 1;
}

static const luaL_Reg largon2[] = {
    {"hash", hash}, {"verify", verify}, {NULL, NULL}};

int luaopen_largon2(lua_State *L) {
    luaL_newlib(L, largon2);
    return 1;
}
