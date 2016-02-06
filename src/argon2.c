/***
Lua Argon2
Lua binding for the Argon2 password hashing function.
See the [Argon2 documentation](https://github.com/P-H-C/phc-winner-argon2) at
the same time while you consult this binding's documentation.
@module argon2
@author thibaultcha
@release 1.1.1
*/

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <argon2.h>
#include <string.h>

#if LUA_VERSION_NUM < 502
#define luaL_newlib(L, l) (lua_newtable(L), luaL_register(L, NULL, l))
#define lua_rawlen lua_objlen
#endif

/***
Hashing options. When using `encrypt`, the third argument is a table describing
the Argon2 options to use.
@field t_cost Number of iterations (`number`)
    type: number
    default: 2
@field m_cost Sets memory usage to m_cost kibibytes (`number`)
    type: number
    default: 12
@field parallelism Number of threads and compute lanes (`number`)
    type: number
    default: 1
@field argon2d If `true`, will use argon2d hashing (`boolean`)
    type: boolean
    default: false
@table options
*/
#define DEFAULT_T_COST 2
#define DEFAULT_M_COST 12
#define DEFAULT_PARALLELISM 1

const uint32_t ENCODED_LEN = 108u;
const uint32_t HASH_LEN = 32u;

void get_option(lua_State *L, const char *key, uint32_t *opt) {
    lua_getfield(L, -1, key);
    if (!lua_isnil(L, -1)) {
        if (lua_isnumber(L, -1)) {
            *opt = lua_tonumber(L, -1);
        } else {
            luaL_error(L, "expected %s to be a number", key);
        }
    }
    lua_pop(L, 1);
}

/***
Encrypt a plain string. Uses Argon2i (by default) or Argon2d to hash a password
(or any plain string).
@function encrypt
@param[type=string] pwd Password (or plain string) to hash.
@param[type=string] salt Salt to use to hash pwd. Must not exceed 16 characters.
@param[type=table] options Options with which to hash the plain string. See
`options`.
@treturn string `hash`: Hash computed by Argon2 or nil if an error occurred.
@treturn string `error`: `nil` or a string describing the error if any.
*/
static int encrypt(lua_State *L) {
    lua_settop(L, 3);

    char encoded[ENCODED_LEN];

    const char *plain, *salt;
    size_t plainlen, saltlen;

    uint32_t t_cost = DEFAULT_T_COST;
    uint32_t m_cost = DEFAULT_M_COST;
    uint32_t parallelism = DEFAULT_PARALLELISM;

    argon2_type type = Argon2_i;

    plain = luaL_checklstring(L, 1, &plainlen);
    salt = luaL_checklstring(L, 2, &saltlen);

    if (!lua_isnil(L, 3)) {
        if (!lua_istable(L, 3)) {
            return luaL_argerror(L, 3, "expected to be a table");
        }
        get_option(L, "t_cost", &t_cost);
        get_option(L, "m_cost", &m_cost);
        get_option(L, "parallelism", &parallelism);

        lua_getfield(L, -1, "argon2d");
        if (!lua_isnil(L, -1) && lua_isboolean(L, -1) && lua_toboolean(L, -1)) {
            type = Argon2_d;
        }
        lua_pop(L, 1);
    }

    argon2_error_codes result =
        argon2_hash(t_cost, m_cost, parallelism, plain, plainlen, salt, saltlen,
                    NULL, HASH_LEN, encoded, ENCODED_LEN, type);
    if (result != ARGON2_OK) {
        const char *err_msg = error_message(result);
        lua_pushnil(L);
        lua_pushstring(L, err_msg);
        return 2;
    }

    lua_pushstring(L, encoded);
    return 1;
}

/***
Verify a plain string against a hash. Uses Argon2i or Argon2d to verify if a
given password (or any plain string) verifies against a hash encrypted with
Argon2.
@function verify
@param[type=string] encrypted Hash to verify the plain string against.
@param[type=string] plain Plain string to verify.
@treturn boolean `ok`: `true` if the password matched, `false` otherwise.
@treturn string `error`: `nil` or a string describing the error if any.
*/
static int verify(lua_State *L) {
    lua_settop(L, 3);

    const char *plain, *encoded;
    argon2_type type = Argon2_i;
    size_t plainlen;

    encoded = luaL_checkstring(L, 1);
    plain = luaL_checklstring(L, 2, &plainlen);
    if (strstr(encoded, "argon2d")) {
        type = Argon2_d;
    }

    argon2_error_codes result = argon2_verify(encoded, plain, plainlen, type);
    if (result != ARGON2_OK) {
        lua_pushboolean(L, 0);
        lua_pushliteral(L, "The password did not match.");
        return 2;
    }

    lua_pushboolean(L, 1);
    return 1;
}

static const luaL_Reg argon2[] = {
    {"verify", verify}, {"encrypt", encrypt}, {NULL, NULL}};

int luaopen_argon2(lua_State *L) {
    luaL_newlib(L, argon2);

    lua_pushstring(L, "1.1.1");
    lua_setfield(L, -2, "_VERSION");

    lua_pushstring(L, "Thibault Charbonnier");
    lua_setfield(L, -2, "_AUTHOR");

    lua_pushstring(L, "MIT");
    lua_setfield(L, -2, "_LICENSE");

    lua_pushstring(L, "https://github.com/thibaultCha/lua-argon2");
    lua_setfield(L, -2, "_URL");

    return 1;
}
