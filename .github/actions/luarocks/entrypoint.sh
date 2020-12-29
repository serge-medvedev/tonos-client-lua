#!/bin/bash

set -e

LUAROCKS_API_KEY="$1"
VERSION="$2"

printf "%s" "$FUNDING_WALLET_CONFIG" > spec/funding_wallet.lua

tools/codegen.lua /tmp/api.json

luarocks make
luarocks test -- --run=ci

zip -r /usr/src/tonos-client.zip \
    CHANGELOG.md \
    README.md \
    build/generated \
    src

if [ -z "$VERSION" ]; then
    echo 'Uploading the snapshot...'

    luarocks upload --force --api-key "$LUAROCKS_API_KEY" -- tonos-client-scm-1.rockspec
else
    echo 'Uploading the package...'

    ROCKSPEC=`luarocks new_version --tag "$VERSION" | grep Wrote | awk '{print $2}'`

    luarocks upload --force --api-key "$LUAROCKS_API_KEY" "$ROCKSPEC"
fi

