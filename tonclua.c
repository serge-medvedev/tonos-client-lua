#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include "khash.h"
#include "klist.h"
#include <tonclient.h>
#include <callback.h>

typedef struct {
    lua_State *L;
    uint32_t context;
    int ref;
} callback_data_t;
typedef void (*on_response_t)(uint32_t, tc_string_t, tc_string_t, uint32_t);
typedef int (*callback_t)();

#define callback_destructor_dummy(x)

KLIST_INIT(cb, callback_t, callback_destructor_dummy)
KHASH_MAP_INIT_INT64(ctxcb, klist_t(cb) *)

khash_t(ctxcb) * callbacks;

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

    {   // Clean up the context-related callbacks data
        khiter_t k = kh_get(ctxcb, callbacks, context);

        if (k == kh_end(callbacks)) {
            return 0;
        }

        klist_t(cb) * l = kh_value(callbacks, k);
        kliter_t(cb) * p;

        for (p = kl_begin(l); p != kl_end(l); p = kl_next(p)) {
            callback_t cb = p->data;
            callback_data_t * data = callback_data(cb);

            luaL_unref(data->L, LUA_REGISTRYINDEX, data->ref);
            free(data);
            free_callback(cb);
        }

        kl_destroy(cb, l);
        kh_del(ctxcb, callbacks, k);
    }

	return 0;
}

static callback_t create_callback(lua_State *L, uint32_t context, int ref);

int json_request_async(lua_State *L) {
	uint32_t context = luaL_checkinteger(L, 1);
	const char * method_ = luaL_checkstring(L, 2);
	const char * params_json_ = luaL_checkstring(L, 3);
	uint32_t request_id = luaL_checkinteger(L, 4);

	if (0 == lua_isfunction(L, 5)) {
		luaL_typerror(L, 5, "function");
	}

    lua_pushvalue(L, 5);

    int ref = luaL_ref(L, LUA_REGISTRYINDEX);
    callback_t callback = create_callback(L, context, ref);
	tc_string_t method = { method_, strlen(method_) };
	tc_string_t params_json = { params_json_, strlen(params_json_) };

	tc_json_request_async(context, method, params_json, request_id, (on_response_t) callback);

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
    callbacks = kh_init(ctxcb);

	lua_newtable(L);
	luaL_register(L, 0, functions);

	return 1;
}

//
//
//

static void on_response_impl(lua_State *L, uint32_t context, int ref, uint32_t request_id, tc_string_t result_json, tc_string_t error_json, uint32_t flags) {
	lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
	lua_pushinteger(L, request_id);
	result_json.len > 0 ? lua_pushlstring(L, result_json.content, result_json.len) : lua_pushnil(L);
	error_json.len > 0 ? lua_pushlstring(L, error_json.content, error_json.len) : lua_pushnil(L);
	lua_pushinteger(L, flags);

	if (0 != lua_pcall(L, 4, 0, 0)) {
		lua_error(L);
	}
}

static void on_response(void * data_, va_alist alist) {
    va_start_void(alist);

    callback_data_t * data = (callback_data_t *) data_;
    uint32_t request_id = va_arg_uint(alist);
    tc_string_t result_json = va_arg_struct(alist, tc_string_t);
    tc_string_t error_json = va_arg_struct(alist, tc_string_t);
    uint32_t flags = va_arg_uint(alist);

    on_response_impl(data->L, data->context, data->ref, request_id, result_json, error_json, flags);

    va_return_void(alist);
}

static callback_t create_callback(lua_State *L, uint32_t context, int ref) {
    int ret;
	khiter_t k = kh_get(ctxcb, callbacks, context);

	if (k == kh_end(callbacks)) {
        k = kh_put(ctxcb, callbacks, context, &ret);
        kh_value(callbacks, k) = kl_init(cb);
	}

    callback_data_t * data = (callback_data_t *) malloc(sizeof(callback_data_t));

    data->L = L, data->context = context, data->ref = ref;

    callback_t callback = alloc_callback(&on_response, data);

    *kl_pushp(cb, kh_value(callbacks, k)) = callback;

    return callback;
}

