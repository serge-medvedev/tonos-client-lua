#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include "khash.h"
#include <tonclient.h>

typedef struct {
    lua_State *L;
    int r_index;
} lua_cb_t;

KHASH_MAP_INIT_INT64(cb, lua_cb_t)

khash_t(cb) * callbacks;

void tc_on_response(uint32_t request_id, tc_string_t result_json, tc_string_t error_json, uint32_t flags) {
    khiter_t k = kh_get(cb, callbacks, request_id);

    if (k == kh_end(callbacks)) {
        return;
    }

    lua_cb_t cb = kh_value(callbacks, k);
    lua_State *L = cb.L;

    lua_rawgeti(L, LUA_REGISTRYINDEX, cb.r_index);
    lua_pushinteger(L, request_id);
    result_json.len > 0 ? lua_pushlstring(L, result_json.content, result_json.len) : lua_pushnil(L);
    error_json.len > 0 ? lua_pushlstring(L, error_json.content, error_json.len) : lua_pushnil(L);
    lua_pushinteger(L, flags);

    if (0 != lua_pcall(L, 4, 0, 0)) {
        lua_error(L);
    }

    luaL_unref(L, LUA_REGISTRYINDEX, cb.r_index);
    kh_del(cb, callbacks, k);
}

int create_context(lua_State *L) {
    const char * s = luaL_checkstring(L, 1);
    tc_string_t config = { s, strlen(s) };
    tc_response_handle_t * response_handle = tc_create_context(config);

    lua_pushlightuserdata(L, response_handle);

    return 1;
}

int destroy_context(lua_State *L) {
    uint32_t context = luaL_checkinteger(L, 1);

    tc_destroy_context(context);

    return 0;
}

int json_request_async(lua_State *L) {
    uint32_t context = luaL_checkinteger(L, 1);
    const char * method_ = luaL_checkstring(L, 2);
    const char * params_json_ = luaL_checkstring(L, 3);
    uint32_t request_id = luaL_checkinteger(L, 4);

    if (0 == lua_isfunction(L, 5)) {
        luaL_typerror(L, 5, "function");
    }

    lua_pushvalue(L, 5);

    int ret;
    khiter_t k = kh_put(cb, callbacks, request_id, &ret);
    lua_cb_t cb = { L, luaL_ref(L, LUA_REGISTRYINDEX) };

    kh_value(callbacks, k) = cb;

    tc_string_t method = { method_, strlen(method_) };
    tc_string_t params_json = { params_json_, strlen(params_json_) };

    tc_json_request_async(context, method, params_json, request_id, tc_on_response);

    return 0;
}

int json_request(lua_State *L) {
    uint32_t context = luaL_checkinteger(L, 1);
    const char * method_ = luaL_checkstring(L, 2);
    const char * params_json_ = luaL_checkstring(L, 3);
    tc_string_t method = { method_, strlen(method_) };
    tc_string_t params_json = { params_json_, strlen(params_json_) };
    tc_response_handle_t * response_handle = tc_json_request(context, method, params_json);

    lua_pushlightuserdata(L, response_handle);

    return 1;
}

int read_json_response(lua_State *L) {
    tc_response_handle_t * response_handle;

    if (lua_islightuserdata(L, -1)) {
        response_handle = (tc_response_handle_t *) lua_topointer(L, 1);
    }
    else {
        luaL_typerror(L, 1, "lightuserdata");
    }

    tc_response_t response = tc_read_json_response(response_handle);

    if (response.error_json.len > 0) {
        lua_pushlstring(L, response.error_json.content, response.error_json.len);
    }
    else {
        lua_pushnil(L);
    }

    lua_pushlstring(L, response.result_json.content, response.result_json.len);

    tc_destroy_json_response(response_handle);

    return 2;
}

static const struct luaL_Reg functions [] = {
    { "create_context", create_context },
    { "destroy_context", destroy_context },
    { "json_request_async", json_request_async },
    { "json_request", json_request },
    { "read_json_response", read_json_response },
    { NULL, NULL }
};

int luaopen_tonclua(lua_State *L) {
    callbacks = kh_init(cb);

    lua_newtable(L);
    luaL_register(L, 0, functions);

    return 1;
}

