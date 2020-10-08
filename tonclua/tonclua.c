#include <threads.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdatomic.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <tonclient.h>
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include "khash.h"

static const char K = 'K';

atomic_uint_least32_t rid = 0;
mtx_t guard;

FILE * flog;

#define LOG(format, ...) \
    fprintf(flog, format __VA_OPT__(,) __VA_ARGS__); \
    fflush(flog);

#define LOCK() \
    LOG("%s :: lock\n", __func__); \
    mtx_lock(&guard);

#define UNLOCK() \
    LOG("%s :: unlock\n", __func__); \
    mtx_unlock(&guard);

typedef struct {
    lua_State *L;
    uint32_t context;
} contexts_t;

KHASH_MAP_INIT_INT64(r2c, contexts_t)

khash_t(r2c) * r2c;

int create_context(lua_State *L) {
    LOCK();

    const char * s = luaL_checkstring(L, 1);
    tc_string_data_t config = { s, strlen(s) };
    tc_string_handle_t * string_handle = tc_create_context(config);

    lua_pushlightuserdata(L, string_handle);

    UNLOCK();

    return 1;
}

int destroy_context(lua_State *L) {
    // ----------
    LOCK();

    uint32_t context = luaL_checkinteger(L, 1);

    UNLOCK();
    // ==========

    tc_destroy_context(context);

    // ----------
    LOCK();

    lua_pushlightuserdata(L, (void *) &K);
    lua_rawget(L, LUA_REGISTRYINDEX);
    lua_rawgeti(L, -1, context);

    if (lua_isnil(L, -1)) {
        lua_pop(L, 2);

        UNLOCK();

        return 0;
    }

    lua_pushliteral(L, "callbacks");
    lua_rawget(L, -2);
    lua_pushnil(L);

    while (lua_next(L, -2) != 0) {
        lua_pop(L, 1);

        uint32_t request_id = lua_tointeger(L, -1);
        khiter_t k = kh_get(r2c, r2c, request_id);

        if (k != kh_end(r2c)) {
            kh_del(r2c, r2c, k);
        }
    }

    lua_pop(L, 2);
    lua_pushnil(L);
    lua_rawseti(L, -1, context);
    lua_pop(L, 1);

    UNLOCK();
    // ==========

    return 0;
}

static uint32_t next_rid();
static void on_response(uint32_t request_id, tc_string_data_t params_json, uint32_t response_type, bool finished);

int request(lua_State *L) {
    LOCK();

    uint32_t context = luaL_checkinteger(L, 1);
    const char * method_ = luaL_checkstring(L, 2);
    const char * params_json_ = luaL_checkstring(L, 3);
    uint32_t request_id = next_rid();

    if (0 == lua_isfunction(L, 4)) {
        UNLOCK();

        luaL_typerror(L, 4, "function");
    }

    lua_State *L_;

    lua_pushlightuserdata(L, (void *) &K);
    lua_rawget(L, LUA_REGISTRYINDEX);
    lua_rawgeti(L, -1, context);

    if (lua_isnil(L, -1)) {
        lua_pop(L, 1);
        lua_createtable(L, 0, 2);
        lua_rawseti(L, -2, context);
        lua_rawgeti(L, -1, context);
        lua_pushliteral(L, "L");
        L_ = lua_newthread(L);
        lua_rawset(L, -3);
        lua_pushliteral(L, "callbacks");
        lua_newtable(L);
        lua_rawset(L, -3);
    }

    lua_remove(L, -2);
    lua_pushliteral(L, "L");
    lua_rawget(L, -2);
    L_ = lua_tothread(L, -1);
    lua_pop(L, 1);
    lua_pushliteral(L, "callbacks");
    lua_rawget(L, -2);
    lua_pushvalue(L, 4);
    lua_rawseti(L, -2, request_id);
    lua_pop(L, 2);

    int ret;
    khiter_t k = kh_put(r2c, r2c, request_id, &ret);
    contexts_t data = { L_, context };

    kh_value(r2c, k) = data;

    tc_string_data_t method = { method_, strlen(method_) };
    tc_string_data_t params_json = { params_json_, strlen(params_json_) };

    tc_request(context, method, params_json, request_id, &on_response);

    lua_pushinteger(L, request_id);

    UNLOCK();

    return 1;
}

int request_sync(lua_State *L) {
    // ----------
    LOCK();

    uint32_t context = luaL_checkinteger(L, 1);
    const char * method_ = luaL_checkstring(L, 2);
    const char * params_json_ = luaL_checkstring(L, 3);
    tc_string_data_t method = { method_, strlen(method_) };
    tc_string_data_t params_json = { params_json_, strlen(params_json_) };

    UNLOCK();
    // ==========

    tc_string_handle_t * string_handle = tc_request_sync(context, method, params_json);

    // ----------
    LOCK();

    lua_pushlightuserdata(L, string_handle);

    UNLOCK();
    // ==========

    return 1;
}

int read_string(lua_State *L) {
    LOCK();

    tc_string_handle_t * string_handle;

    if (0 == lua_islightuserdata(L, -1)) {
        UNLOCK();

        luaL_typerror(L, 1, "lightuserdata");
    }

    string_handle = (tc_string_handle_t *) lua_topointer(L, 1);

    tc_string_data_t response = tc_read_string(string_handle);

    lua_pushnil(L); // TODO: remove it and fix the function usage everywhere
    lua_pushlstring(L, response.content, response.len);

    tc_destroy_string(string_handle);

    UNLOCK();

    return 2;
}

static const struct luaL_Reg functions [] = {
    { "create_context", create_context },
    { "destroy_context", destroy_context },
    { "request", request },
    { "request_sync", request_sync },
    { "read_string", read_string },
    { NULL, NULL }
};

int luaopen_tonclua(lua_State *L) {
    lua_pushlightuserdata(L, (void *) &K);
    lua_newtable(L);
    lua_rawset(L, LUA_REGISTRYINDEX);

    flog = fopen("/tmp/tonclua.log", "w");

    mtx_init(&guard, mtx_plain);

    r2c = kh_init(r2c);

    lua_newtable(L);
    luaL_register(L, 0, functions);

    return 1;
}

static uint32_t next_rid() {
    atomic_fetch_add_explicit(&rid, 1, memory_order_relaxed);

    return rid;
}

static void on_response(uint32_t request_id, tc_string_data_t params_json, uint32_t response_type, bool finished) {
    LOCK();

    khiter_t k = kh_get(r2c, r2c, request_id);

    if (k == kh_end(r2c)) {
        UNLOCK();

        return;
    }

    contexts_t data = kh_value(r2c, k);
    lua_State *L = data.L;

    lua_pushlightuserdata(L, (void *) &K);
    lua_rawget(L, LUA_REGISTRYINDEX);
    lua_rawgeti(L, -1, data.context);
    lua_remove(L, -2);
    lua_pushliteral(L, "callbacks");
    lua_rawget(L, -2);
    lua_rawgeti(L, -1, request_id);
    lua_remove(L, -2);
    lua_remove(L, -2);
    lua_pushinteger(L, request_id);
    params_json.len > 0 ? lua_pushlstring(L, params_json.content, params_json.len) : lua_pushnil(L);
    lua_pushinteger(L, response_type);
    lua_pushboolean(L, finished);

    if (0 != lua_pcall(L, 4, 0, 0)) {
        UNLOCK();

        lua_error(L);
    }

    UNLOCK();
}

