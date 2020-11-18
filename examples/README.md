# Examples HOWTO

Examples may require minor modifications (addresses, keys, etc.) to get ready to play with.

Look for placeholders like `"..."` for hints.

## Build
```console
$ cd <example directory>
$ docker build -f ../commons/Dockerfile -t tonos-client-lua-example .
```

## Run
```console
$ docker run --rm tonos-client-lua-example
```
