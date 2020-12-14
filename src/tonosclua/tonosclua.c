#include <assert.h>
#include <threads.h>
#include <time.h>
#include <stdatomic.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdio.h>
#include <stdbool.h>
#include <tonclient.h>
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include "khash.h"
#include "klist.h"

// --------------------------------------------------------------------------------

KHASH_MAP_INIT_INT64(R2C, uint32_t)

typedef struct {
    uint32_t request_id;
    tc_string_data_t params_json;
    uint32_t response_type;
    bool finished;
} resdata_t;

#define dummy_destructor(x)

KLIST_INIT(Q, resdata_t, dummy_destructor)
KHASH_MAP_INIT_INT64(R2Q, klist_t(Q) *)
KHASH_MAP_INIT_INT64(C2QS, khash_t(R2Q) *)

// --------------------------------------------------------------------------------

atomic_uint_least32_t rid = 0;
atomic_flag everything_is_initialized = ATOMIC_FLAG_INIT;
mtx_t guard;
cnd_t cbcv;
khash_t(R2C) * request_context;
khash_t(C2QS) * context_queues;

// --------------------------------------------------------------------------------

#ifdef ENABLE_LOGGING
FILE * flog;

#define LOG(...) \
    fprintf(flog, __VA_ARGS__); \
    fflush(flog);
#else
#define LOG(...)
#endif

// --------------------------------------------------------------------------------

int create_context(lua_State *L) {
    lua_settop(L, 1);

    const char * s = luaL_checkstring(L, 1);
    tc_string_data_t config = { s, strlen(s) };
    tc_string_handle_t * string_handle = tc_create_context(config);
    tc_string_data_t response = tc_read_string(string_handle);
    uint32_t context;

    sscanf(response.content, "{\"result\":%u}", &context);

    tc_destroy_string(string_handle);

    mtx_lock(&guard);

    int ret;
    khiter_t k = kh_put(C2QS, context_queues, context, &ret);
    kh_val(context_queues, k) = kh_init(R2Q);

    mtx_unlock(&guard);

    lua_pushinteger(L, context);

    return 1;
}

int destroy_context(lua_State *L) {
    lua_settop(L, 1);

    uint32_t context = luaL_checkinteger(L, 1);

    tc_destroy_context(context);

    LOG("locking @ destroy_context [context = %u]\n", context);
    mtx_lock(&guard);

    khiter_t k = kh_get(C2QS, context_queues, context);
    assert(kh_size(kh_val(context_queues, k)) == 0);
    kh_del(C2QS, context_queues, k);

    LOG("unlocking @ destroy_context [context = %u]\n", context);
    mtx_unlock(&guard);

    return 0;
}

static uint32_t next_rid();
static void on_response(uint32_t request_id, tc_string_data_t params_json, uint32_t response_type, bool finished);

int request(lua_State *L) {
    lua_settop(L, 3);

    uint32_t request_id = next_rid();
    uint32_t context = luaL_checkinteger(L, 1);
    const char * method_ = luaL_checkstring(L, 2);
    const char * params_json_ = luaL_checkstring(L, 3);

    LOG("locking @ %s [request_id = %d]\n", "request", request_id);
    mtx_lock(&guard);

    int ret;
    khiter_t k = kh_put(R2C, request_context, request_id, &ret);
    kh_val(request_context, k) = context; // create "request_id -> context" mapping
    k = kh_get(C2QS, context_queues, context);
    assert(k != kh_end(context_queues));
    khash_t(R2Q) * r2q = kh_val(context_queues, k);
    k = kh_put(R2Q, r2q, request_id, &ret);
    kh_val(r2q, k) = kl_init(Q); // create a queue for responses

    LOG("unlocking @ %s [request_id = %d]\n", "request", request_id);
    mtx_unlock(&guard);

    tc_string_data_t method = { method_, strlen(method_) };
    tc_string_data_t params_json = { params_json_, strlen(params_json_) };

    LOG("tc_request [context = %u, method = %s, params_json = %s, request_id = %d]\n",
        context, method_, params_json_, request_id);

    tc_request(context, method, params_json, request_id, &on_response);

    lua_pushinteger(L, request_id);

    return 1;
}

int request_sync(lua_State *L) {
    lua_settop(L, 3);

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
    lua_settop(L, 1);

    tc_string_handle_t * string_handle;

    if (lua_islightuserdata(L, 1) == 0) {
        luaL_typerror(L, 1, "lightuserdata");
    }

    string_handle = (tc_string_handle_t *) lua_topointer(L, 1);

    tc_string_data_t response = tc_read_string(string_handle);

    lua_pushlstring(L, response.content, response.len);

    tc_destroy_string(string_handle);

    return 1;
}

int fetch_response_data(lua_State *L) {
    lua_settop(L, 2);

    uint32_t context = luaL_checkinteger(L, 1);
    uint32_t request_id = luaL_checkinteger(L, 2);

    LOG("locking @ %s [context = %u, request_id = %d]\n", "fetch_response_data", context, request_id);
    mtx_lock(&guard);

    khiter_t k = kh_get(C2QS, context_queues, context);
    assert(k != kh_end(context_queues));
    khash_t(R2Q) * r2q = kh_val(context_queues, k);
    k = kh_get(R2Q, r2q, request_id);

    if (k == kh_end(r2q)) {
        LOG("unlocking @ fetch_response_data [request_id = %d] - no such request entry\n", request_id);

        mtx_unlock(&guard);

        lua_pushinteger(L, request_id);

        return 1;
    }

    klist_t(Q) * q = kh_val(r2q, k);
    kliter_t(Q) * p = kl_begin(q);

    LOG("waiting for data [context = %u, request_id = %d]...\n", context, request_id);

    while (p == kl_end(q)) {
        cnd_wait(&cbcv, &guard); // TODO: consider using timeout

        p = kl_begin(q);
    }

    LOG("data is ready [context = %u, request_id = %d]...\n", context, request_id);

    resdata_t data = kl_val(p);

    lua_pushinteger(L, data.request_id);
    lua_pushlstring(L, data.params_json.content, data.params_json.len);
    lua_pushinteger(L, data.response_type);
    lua_pushboolean(L, data.finished);

    if (data.params_json.len > 0) {
        free((char *) data.params_json.content);
    }

    kl_shift(Q, q, NULL); // remove response data from the queue

    if (data.finished) {
        LOG("data queue is about to be dropped [context = %u, request_id = %d]\n", context, request_id);

        kl_destroy(Q, q); // destroy the empty queue
        kh_del(R2Q, r2q, k); // delete the queue entry
        k = kh_get(R2C, request_context, request_id);
        kh_del(R2C, request_context, k); // delete the "request_id -> context" mapping
    }

    LOG("unlocking @ %s [context = %u, request_id = %d]\n", "fetch_response_data", context, request_id);
    mtx_unlock(&guard);

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
    if (! atomic_flag_test_and_set(&everything_is_initialized)) {
        mtx_init(&guard, mtx_plain);
        cnd_init(&cbcv);

#ifdef ENABLE_LOGGING
        flog = fopen("/tmp/tonosclua.log", "w");
#endif

        request_context = kh_init(R2C);
        context_queues = kh_init(C2QS);
    }

    lua_newtable(L);
    luaL_register(L, 0, functions);

    return 1;
}

static uint32_t next_rid() {
    atomic_fetch_add_explicit(&rid, 1, memory_order_relaxed);

    return rid;
}

static void on_response(uint32_t request_id, tc_string_data_t params_json, uint32_t response_type, bool finished) {
    if (params_json.len > 0) {
        char * buffer = malloc(params_json.len);
        strncpy(buffer, params_json.content, params_json.len);
        params_json.content = buffer;
    }

    resdata_t data = { request_id, params_json, response_type, finished };

    LOG("locking @ %s [request_id = %d]\n", "on_response", request_id);
    mtx_lock(&guard);

    khiter_t k = kh_get(R2C, request_context, request_id);
    assert(k != kh_end(request_context)); // "request_id -> context" mapping exists
    uint32_t context = kh_val(request_context, k);
    k = kh_get(C2QS, context_queues, context);
    assert(k != kh_end(context_queues)); // "context -> queues" mapping exists
    khash_t(R2Q) * r2q = kh_val(context_queues, k);
    k = kh_get(R2Q, r2q, request_id);
    assert(k != kh_end(r2q)); // queue exists
    *kl_pushp(Q, kh_val(r2q, k)) = data;

    LOG("unlocking @ %s [request_id = %d]\n", "on_response", request_id);
    mtx_unlock(&guard);

    cnd_broadcast(&cbcv);
}

