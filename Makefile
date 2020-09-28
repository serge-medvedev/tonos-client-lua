CFLAGS+=-fPIC -shared -I/usr/include/lua5.1 -L/usr/lib/x86_64-linux-gnu
LDFLAGS+=-llua5.1 -lton_client

tc_lua_wrapper.so: tc_lua_wrapper.c
	$(CC) $(CFLAGS) tc_lua_wrapper.c -o $@ $(LDFLAGS)

install:

clean:
	$(RM) tc_lua_wrapper.so

test: tc_lua_wrapper.so
	shake tc_lua_wrapper.test.lua

rock:
	luarocks make ton-client-scm-1.rockspec

