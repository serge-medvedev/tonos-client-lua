CFLAGS+=-fPIC -shared -I/usr/include/lua5.1 -L/usr/lib/x86_64-linux-gnu
LDFLAGS+=-lffcall -llua5.1 -lton_client

tonclua.so: tonclua.c
	$(CC) $(CFLAGS) tonclua.c -o $@ $(LDFLAGS)

install:
	cp tonclua.so /usr/lib/x86_64-linux-gnu/lua/5.1/

clean:
	$(RM) tonclua.so

test: tonclua.so
	shake -r

rock:
	luarocks make ton-client-scm-1.rockspec

