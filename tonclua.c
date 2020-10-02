#include <stdatomic.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <assert.h>
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include "khash.h"
#include "klist.h"
#include <tonclient.h>

static char buffer[17];
atomic_uint_least32_t rid = 0;

typedef struct {
    lua_State *L;
    int ref;
} callback_data_t;

KHASH_MAP_INIT_INT64(cd, callback_data_t)

    khash_t(cd) * cd;

#define dummy(x)

KLIST_INIT(reqs, uint32_t, dummy)
KHASH_MAP_INIT_INT64(ctxs, klist_t(reqs) *)

khash_t(ctxs) * ctxs;

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

    khiter_t k = kh_get(ctxs, ctxs, context);

    if (k != kh_end(ctxs)) {
        klist_t(reqs) * l = kh_value(ctxs, k);
        kliter_t(reqs) * p;

        for (p = kl_begin(l); p != kl_end(l); p = kl_next(p)) {
            khiter_t k = kh_get(cd, cd, kl_val(p));

            if (kh_exist(cd, k)) {
                callback_data_t data = kh_value(cd, k);

                lua_getfield(L, LUA_REGISTRYINDEX, buffer);
                luaL_unref(L, -1, data.ref);
                lua_pop(L, 1);

                kh_del(cd, cd, k);
            }
        }

        kl_destroy(reqs, l);
        kh_del(ctxs, ctxs, k);
    }

    return 0;
}

static uint32_t next_rid();
static void on_response(uint32_t request_id, tc_string_t result_json, tc_string_t error_json, uint32_t flags);

int json_request_async(lua_State *L) {
    uint32_t context = luaL_checkinteger(L, 1);
    const char * method_ = luaL_checkstring(L, 2);
    const char * params_json_ = luaL_checkstring(L, 3);
    uint32_t request_id = next_rid();

    if (0 == lua_isfunction(L, 4)) {
        luaL_typerror(L, 4, "function");
    }

    int ref, ret;
    khiter_t k;

    lua_getfield(L, LUA_REGISTRYINDEX, buffer);
    lua_pushvalue(L, 4);
    ref = luaL_ref(L, -2);
    lua_pop(L, 1);

    k = kh_get(ctxs, ctxs, context);

    if (k == kh_end(ctxs)) {
        k = kh_put(ctxs, ctxs, context, &ret);
        kh_value(ctxs, k) = kl_init(reqs);
    }

    *kl_pushp(reqs, kh_value(ctxs, k)) = request_id;

    tc_string_t method = { method_, strlen(method_) };
    tc_string_t params_json = { params_json_, strlen(params_json_) };
    callback_data_t data = { L, ref };

    k = kh_put(cd, cd, request_id, &ret);
    kh_value(cd, k) = data;

    tc_json_request_async(context, method, params_json, request_id, &on_response);

    lua_pushinteger(L, request_id);

    return 1;
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
    sprintf(buffer, "tonclua_%08p", &buffer);

    lua_newtable(L);
    lua_setfield(L, LUA_REGISTRYINDEX, buffer);

    cd = kh_init(cd);
    ctxs = kh_init(ctxs);

    lua_newtable(L);
    luaL_register(L, 0, functions);

    return 1;
}

static uint32_t next_rid() {
    atomic_fetch_add_explicit(&rid, 1, memory_order_relaxed);

    return rid;
}

static void on_response(uint32_t request_id, tc_string_t result_json, tc_string_t error_json, uint32_t flags) {
    khiter_t k = kh_get(cd, cd, request_id);

    if (k == kh_end(cd)) {
        return;
    }

    callback_data_t data = kh_value(cd, k);
    lua_State *L = data.L;

    lua_pushstring(L, buffer);
    lua_rawget(L, LUA_REGISTRYINDEX);
    lua_rawgeti(L, -1, data.ref);
    lua_pushinteger(L, request_id);
    result_json.len > 0 ? lua_pushlstring(L, result_json.content, result_json.len) : lua_pushnil(L);
    error_json.len > 0 ? lua_pushlstring(L, error_json.content, error_json.len) : lua_pushnil(L);
    lua_pushinteger(L, flags);

    if (0 != lua_pcall(L, 4, 0, 0)) {
        lua_error(L);
    }

    lua_pop(L, 1);
}

