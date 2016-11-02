/***
Lua C binding for the Argon2 password hashing algorithm.
See the [Argon2 documentation](https://github.com/P-H-C/phc-winner-argon2) at
the same time while you consult this binding's documentation.

Note: this document is also valid for [lua-argon2-ffi]
(https://github.com/thibaultcha/lua-argon2-ffi) which uses the same prototype
for its `encrypt` and `verify` functions.

@module argon2
@author Thibault Charbonnier
@license MIT
@release 2.0.0
*/

#include <argon2.h>
#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>
#include <string.h>

/***
Argon2 hashing options. Those options can be given to `encrypt` as a table.
If values are omitted, the default values will be used.
Default values can be overriden with `m_cost`, `t_cost`, `parallelism` and
`argon2d`.
@field t_cost Number of iterations (`number`, default: `2`).
Can be set to a new default in lua-argon2 (C binding only) by calling:
    argon2.t_cost(4)
@field m_cost Sets memory usage to m_cost kibibytes (`number`, default: `12`).
Can be set to a new default in lua-argon2 (C binding only) by calling:
    argon2.m_cost(4)
@field parallelism Number of threads and compute lanes (`number`, default: `1`).
Can be set to a new default in lua-argon2 (C binding only) by calling:
    argon2.parallelism(2)
@field argon2d If `true`, will use the Argon2d hashing function (`boolean`,
default: `false`).
Can be set to a new default in lua-argon2 (C binding only) by calling:
    argon2.argon2d(true)
    argon2.argon2d("on")
@table options
*/
#define DEFAULT_T_COST 2
#define DEFAULT_M_COST 12
#define DEFAULT_PARALLELISM 1

static const uint32_t ENCODED_LEN = 108u;
static const uint32_t HASH_LEN = 32u;

typedef struct {
    uint32_t m_cost;
    uint32_t t_cost;
    uint32_t parallelism;
    argon2_type argon2_t;
} largon2_config;

// CONFIGURATION

static void largon2_create_config(lua_State *L) {
    largon2_config *cfg;

    cfg = lua_newuserdata(L, sizeof(*cfg));
    cfg->t_cost = DEFAULT_T_COST;
    cfg->m_cost = DEFAULT_M_COST;
    cfg->parallelism = DEFAULT_PARALLELISM;
    cfg->argon2_t = Argon2_i;
}

static largon2_config *largon2_fetch_config(lua_State *L) {
    largon2_config *cfg;

    cfg = lua_touserdata(L, lua_upvalueindex(1));
    if (!cfg)
        luaL_error(L, "could not retrieve argon2 config");

    return cfg;
}

static largon2_config *largon2_arg_init(lua_State *L, int nargs) {
    luaL_argcheck(L, lua_gettop(L) <= nargs, nargs + 1,
                  "found too many arguments");

    while (lua_gettop(L) < nargs)
        lua_pushnil(L);

    return largon2_fetch_config(L);
}

static void largon2_integer_opt(lua_State *L, uint32_t optidx, uint32_t argidx,
                                uint32_t *property, const char *key) {
    char errmsg[64];
    uint32_t value;

    if (!lua_isnil(L, optidx)) {
        if (lua_isnumber(L, optidx)) {
            value = lua_tonumber(L, optidx);
            *property = value;
        } else {
            const char *type = luaL_typename(L, optidx);
            snprintf(errmsg, sizeof(errmsg),
                     "expected %s to be a number, got %s", key, type);
            luaL_argerror(L, argidx, errmsg);
        }
    }
}

static int largon2_cfg_t_cost(lua_State *L) {
    largon2_config *cfg = largon2_arg_init(L, 1);

    largon2_integer_opt(L, 1, 1, &cfg->t_cost, "t_cost");
    lua_pushinteger(L, cfg->t_cost);

    return 1;
}

static int largon2_cfg_m_cost(lua_State *L) {
    largon2_config *cfg = largon2_arg_init(L, 1);

    largon2_integer_opt(L, 1, 1, &cfg->m_cost, "m_cost");
    lua_pushinteger(L, cfg->m_cost);

    return 1;
}

static int largon2_cfg_parallelism(lua_State *L) {
    largon2_config *cfg = largon2_arg_init(L, 1);

    largon2_integer_opt(L, 1, 1, &cfg->parallelism, "parallelism");
    lua_pushinteger(L, cfg->parallelism);

    return 1;
}

static int largon2_cfg_argon2d(lua_State *L) {
    static const char *bool_options[] = {"off", "on", NULL};

    int value;

    largon2_config *cfg = largon2_arg_init(L, 1);

    if (!lua_isnil(L, 1)) {
        if (lua_isboolean(L, 1)) {
            value = lua_toboolean(L, 1);
            lua_pushboolean(L, value);
        } else {
            value = luaL_checkoption(L, 1, NULL, bool_options);
            lua_pushstring(L, bool_options[value]);
        }
    } else {
        value = 0;
        lua_pushboolean(L, 0);
    }

    cfg->argon2_t = value ? Argon2_d : Argon2_i;

    return 1;
}

// BINDINGS

/***
Encrypt a plain string. Use Argon2i (by default) or Argon2d to hash a string.
@function encrypt
@param[type=string] plain Plain string to encrypt.
@param[type=string] salt Salt to use to hash pwd.
@param[type=table] options Options with which to hash the plain string. See
`options`. This parameter is optional, if values are omitted the default ones
will be used.
@treturn string `hash`: Hash computed by Argon2 or nil if an error occurred.
@treturn string `error`: `nil` or a string describing the error if any.

@usage
local hash, err = argon2.encrypt("password", "somesalt")
local hash, err = argon2.encrypt("password", "somesalt", {t_cost = 4})
*/
static int largon2_encrypt(lua_State *L) {
    largon2_config *cfg = largon2_arg_init(L, 3);

    char encoded[ENCODED_LEN];
    int ret_code;

    const char *plain, *salt;
    size_t plainlen, saltlen;

    uint32_t t_cost;
    uint32_t m_cost;
    uint32_t parallelism;
    argon2_type argon2_t;

    plain = luaL_checklstring(L, 1, &plainlen);
    salt = luaL_checklstring(L, 2, &saltlen);

    t_cost = cfg->t_cost;
    m_cost = cfg->m_cost;
    parallelism = cfg->parallelism;
    argon2_t = cfg->argon2_t;

    if (!lua_isnil(L, 3)) {
        if (!lua_istable(L, 3)) {
            luaL_argerror(L, 3, "expected to be a table");
        }

        lua_getfield(L, 3, "t_cost");
        largon2_integer_opt(L, -1, 3, &t_cost, "t_cost");
        lua_pop(L, 1);

        lua_getfield(L, 3, "m_cost");
        largon2_integer_opt(L, -1, 3, &m_cost, "m_cost");
        lua_pop(L, 1);

        lua_getfield(L, 3, "parallelism");
        largon2_integer_opt(L, -1, 3, &parallelism, "parallelism");
        lua_pop(L, 1);

        lua_getfield(L, -1, "argon2d");
        if (!lua_isnil(L, -1) && lua_isboolean(L, -1)) {
            // reverse checking to allow overriding the module settings
            argon2_t = lua_toboolean(L, -1) ? Argon2_d : Argon2_i;
        }

        lua_pop(L, 1);
    }

    if (argon2_t == Argon2_i)
        ret_code =
            argon2i_hash_encoded(t_cost, m_cost, parallelism, plain, plainlen,
                                 salt, saltlen, HASH_LEN, encoded, ENCODED_LEN);
    else
        ret_code =
            argon2d_hash_encoded(t_cost, m_cost, parallelism, plain, plainlen,
                                 salt, saltlen, HASH_LEN, encoded, ENCODED_LEN);

    if (ret_code != ARGON2_OK) {
        const char *err_msg = argon2_error_message(ret_code);
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

@usage
local ok, err = argon2.verify(argon2i_hash, "password")
local ok, err = argon2.verify(argon2d_hash, "password")
*/
static int largon2_verify(lua_State *L) {
    largon2_arg_init(L, 2);

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

// MODULE

#if !defined(LUA_VERSION_NUM) || LUA_VERSION_NUM < 502
/* Compatibility for Lua 5.1.
 *
 * luaL_setfuncs() is used to create a module table where the functions have
 * largon2_config as their first upvalue. Code borrowed from Lua 5.2 source. */
static void luaL_setfuncs(lua_State *l, const luaL_Reg *reg, int nup) {
    int i;

    luaL_checkstack(l, nup, "too many upvalues");
    for (; reg->name != NULL; reg++) { /* fill the table with given functions */
        for (i = 0; i < nup; i++)      /* copy upvalues to the top */
            lua_pushvalue(l, -nup);
        lua_pushcclosure(l, reg->func, nup); /* closure with those upvalues */
        lua_setfield(l, -(nup + 2), reg->name);
    }
    lua_pop(l, nup); /* remove upvalues */
}
#endif

static const luaL_Reg largon2[] = {{"verify", largon2_verify},
                                   {"encrypt", largon2_encrypt},
                                   {"t_cost", largon2_cfg_t_cost},
                                   {"m_cost", largon2_cfg_m_cost},
                                   {"parallelism", largon2_cfg_parallelism},
                                   {"argon2d", largon2_cfg_argon2d},
                                   {NULL, NULL}};

int luaopen_argon2(lua_State *L) {
    lua_newtable(L);

    largon2_create_config(L);
    luaL_setfuncs(L, largon2, 1);

    lua_pushstring(L, "2.0.0");
    lua_setfield(L, -2, "_VERSION");

    lua_pushstring(L, "Thibault Charbonnier");
    lua_setfield(L, -2, "_AUTHOR");

    lua_pushstring(L, "MIT");
    lua_setfield(L, -2, "_LICENSE");

    lua_pushstring(L, "https://github.com/thibaultcha/lua-argon2");
    lua_setfield(L, -2, "_URL");

    return 1;
}
