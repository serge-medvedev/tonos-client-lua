#include <threads.h>
#include <stdatomic.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <tonclient.h>
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include "khash.h"
#include "klist.h"

typedef struct {
    uint32_t request_id;
    tc_string_data_t params_json;
    uint32_t response_type;
    bool finished;
} response_data_t;

#define dummy_destructor(x)

KLIST_INIT(rdata, response_data_t, dummy_destructor)

typedef struct {
    uint32_t context;
    klist_t(rdata) * responses_data;
} request_data_t;

KHASH_MAP_INIT_INT64(rdata, request_data_t)

atomic_uint_least32_t rid = 0;
mtx_t guard;
cnd_t cbcv;

khash_t(rdata) * requests_data;

// --------------------------------------------------------------------------------

int create_context(lua_State *L) {
    const char * s = luaL_checkstring(L, 1);
    tc_string_data_t config = { s, strlen(s) };
    tc_string_handle_t * string_handle = tc_create_context(config);

    lua_pushlightuserdata(L, string_handle);

    return 1;
}

int destroy_context(lua_State *L) {
    uint32_t context = luaL_checkinteger(L, 1);

    tc_destroy_context(context);

    return 0;
}

static uint32_t next_rid();
static void on_response(uint32_t request_id, tc_string_data_t params_json, uint32_t response_type, bool finished);

int request(lua_State *L) {
    uint32_t context = luaL_checkinteger(L, 1);
    const char * method_ = luaL_checkstring(L, 2);
    uint32_t request_id = next_rid();

    {
        mtx_lock(&guard);

        int ret;
        khiter_t k = kh_put(rdata, requests_data, request_id, &ret);
        request_data_t data = { context, kl_init(rdata) };

        kh_val(requests_data, k) = data;

        mtx_unlock(&guard);
    }

    const char * params_json_ = luaL_checkstring(L, 3);
    tc_string_data_t method = { method_, strlen(method_) };
    tc_string_data_t params_json = { params_json_, strlen(params_json_) };

    tc_request(context, method, params_json, request_id, &on_response);

    lua_pushinteger(L, request_id);

    return 1;
}

int request_sync(lua_State *L) {
    uint32_t context = luaL_checkinteger(L, 1);
    const char * method_ = luaL_checkstring(L, 2);
    const char * params_json_ = luaL_checkstring(L, 3);
    tc_string_data_t method = { method_, strlen(method_) };
    tc_string_data_t params_json = { params_json_, strlen(params_json_) };

    tc_string_handle_t * string_handle = tc_request_sync(context, method, params_json);

    lua_pushlightuserdata(L, string_handle);

    return 1;
}

int read_string(lua_State *L) {
    tc_string_handle_t * string_handle;

    if (0 == lua_islightuserdata(L, -1)) {
        luaL_typerror(L, 1, "lightuserdata");
    }

    string_handle = (tc_string_handle_t *) lua_topointer(L, 1);

    tc_string_data_t response = tc_read_string(string_handle);

    lua_pushlstring(L, response.content, response.len);

    tc_destroy_string(string_handle);

    return 1;
}

int fetch_response_data(lua_State *L) {
    uint32_t request_id = luaL_checkinteger(L, 1);

    {
        mtx_lock(&guard);

        khiter_t k = kh_get(rdata, requests_data, request_id);

        if (k == kh_end(requests_data)) {
            mtx_unlock(&guard);

            lua_pushinteger(L, request_id);

            return 1;
        }

        klist_t(rdata) * rd = kh_val(requests_data, k).responses_data;
        kliter_t(rdata) * p = kl_begin(rd);

        while (p == kl_end(rd)) {
            cnd_wait(&cbcv, &guard); // TODO: consider using timeout

            p = kl_begin(rd);
        }

        response_data_t data = kl_val(p);

        lua_pushinteger(L, data.request_id);
        lua_pushlstring(L, data.params_json.content, data.params_json.len);
        lua_pushinteger(L, data.response_type);
        lua_pushboolean(L, data.finished);

        free((char *) data.params_json.content);

        kl_shift(rdata, rd, NULL); // remove response data from the queue

        if (data.finished) { // check if request data can be safely dropped
            kl_destroy(rdata, rd);
            k = kh_get(rdata, requests_data, request_id);
            kh_del(rdata, requests_data, k);
        }

        mtx_unlock(&guard);
    }

    return lua_yield(L, 4);
}

static const struct luaL_Reg functions [] = {
    { "create_context", create_context },
    { "destroy_context", destroy_context },
    { "request", request },
    { "request_sync", request_sync },
    { "read_string", read_string },
    { "fetch_response_data", fetch_response_data },
    { NULL, NULL }
};

int luaopen_tonosclua(lua_State *L) {
    mtx_init(&guard, mtx_plain);
    cnd_init(&cbcv);

    requests_data = kh_init(rdata);

    lua_newtable(L);
    luaL_register(L, 0, functions);

    return 1;
}

static uint32_t next_rid() {
    atomic_fetch_add_explicit(&rid, 1, memory_order_relaxed);

    return rid;
}

static void on_response(uint32_t request_id, tc_string_data_t params_json, uint32_t response_type, bool finished) {
    {
        mtx_lock(&guard);

        khiter_t k = kh_get(rdata, requests_data, request_id);

        if (k == kh_end(requests_data)) {
            mtx_unlock(&guard);

            return;
        }

        klist_t(rdata) * rd = kh_val(requests_data, k).responses_data;
        response_data_t data = { request_id, params_json, response_type, finished };
        char * content = (char *) malloc((1 + params_json.len) * sizeof(char));

        strncpy(content, params_json.content, params_json.len);

        data.params_json.content = content;

        *kl_pushp(rdata, rd) = data; // TODO: consider limiting its length

        mtx_unlock(&guard);
    }

    cnd_signal(&cbcv);
}

