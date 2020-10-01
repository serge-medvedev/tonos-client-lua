CFLAGS+=-fPIC -shared -I/usr/include/lua5.1 -L/usr/local/lib/x86_64-linux-gnu
LDFLAGS+=-lffcall -llua5.1 -lton_client

tonclua.so: tonclua.c
	$(CC) $(CFLAGS) tonclua.c -o $@ $(LDFLAGS)

install: tonclua.so
	cp tonclua.so /usr/local/lib/lua/5.1/

clean:
	rm -f tonclua.so

test: tonclua.so
	busted --lpath='./abi/?.lua;./boc/?.lua;./client/?.lua;./crypto/?.lua;./net/?.lua;./processing/?.lua' -- .

rock:
	luarocks make ton-client-scm-0.rockspec

