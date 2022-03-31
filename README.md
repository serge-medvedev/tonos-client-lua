![LuaRocks](https://img.shields.io/luarocks/v/serge-medvedev/tonos-client)
![Testing](https://github.com/serge-medvedev/tonos-client-lua/workflows/tests/badge.svg)

# Lua bindings to TON SDK's Core Client Library

## Why Lua?
- Nginx and Apache HTTP Server can use Lua for configuration
- HAProxy can be extended using Lua
- Redis uses Lua for its "stored procedures"
- In science,  [Foldit](https://fold.it) uses Lua for user scripts
- In game development, Lua is the most popular scripting language...
- ... and [more](https://en.wikipedia.org/wiki/List_of_applications_using_Lua)

These are opportunities for a great many possible use cases.

## Usage
### Prerequisites
- lua 5.1
- luarocks 3
- _libton_client.so_ and _tonclient.h_ are accessible somewhere at well-known locations
  ```console
  $ wget https://raw.githubusercontent.com/tonlabs/TON-SDK/1.32.0/ton_client/client/tonclient.h -O /usr/include/tonclient.h \
    && wget http://sdkbinaries-ws.tonlabs.io/tonclient_1_32_0_linux.gz -O /usr/lib/libton_client.so.gz \
    && gunzip /usr/lib/libton_client.so.gz
  ```

### Example
```console
$ luarocks install tonos-client
```
```lua
local lib = require("tonos.client")
local context, client = lib.context, lib.client
local ctx = context.create('{"network":{"server_address":"https://net.ton.dev"}}')
local result = client.version(ctx).await()

print(result.version)
```

Refer to [examples](examples/) directory for more code snippets and demos.

## Features

The bindings code itself is auto-generated, so the main focus is made on uniformity and consistency of user experience.
To avoid callback hell, the implementation abstracts away asynchronous machinery by utilizing a few low-level tricks behind generator-like constructs and Lua's generic __for__ loop.

For example, when we need to monitor all the events initiated by `processing.process_message`, we write the following code:

```lua
for request_id, params_json, response_type, finished
    in processing.process_message(context, params) do

    local response = json.decode(params_json)

    -- work with decoded response

    if response_type == 1 then
        -- handle error if any
    end

    if finished then
        -- do something special at the end of a stream
    end
end
```

If we're not interested in events generated by the request and just want it to do the job, we might do this:

```lua
processing.process_message(context, params).await()
```
A call like that will block until request is finished.
> NOTE: there's a negative test for `crypto.factorize` which provides an example of dealing with error objects

Under the hood there are coroutines, being initiated and resumed on the Lua-side and yielding on the C-side when new data, received via callback function, appears in the queue. When all the events are fetched on the Lua-side, request-related resources are automatically and safely freed on the C-side.

Such design allows interesting co-operative multitasking approaches to be utilized (see [debot tests](spec/debot_spec.lua) for example).

## Building

The simplest way to build the library and run the tests is by having Docker installed.

When ready, build the image:
```console
$ docker build -t tonos-client-lua .
```

## Testing

The library has over 60 tests.

There are four categories of them:
- fast & slow
- free & paid

And it's also good to know that:
- all __fast__ tests are __free__ and all __paid__ tests are __slow__
- all __free__ tests are being run automatically as a Docker image build step
- some tests depend on either DevNet or MainNet accessibility

The __paid__ tests are those which require account funding, e.g. for successful contract deployment. To run them, you need to:
- have a wallet on the [DevNet](https://net.ton.dev) with some tokens in it
- create a file called _funding_wallet.lua_ under the _spec_ directory based on [funding_wallet.lua.example](spec/funding_wallet.lua.example)

When ready, do the following:
```console
$ docker run --rm tonos-client-lua busted --run=paid
```
> NOTE: replace "paid" with another name to run specific category of tests. Get rid of "--run" argument to run the whole test suite.
