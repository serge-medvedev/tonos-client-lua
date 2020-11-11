#!/bin/bash

set -e

tools/codegen.lua /tmp/api.json

luarocks make
luarocks test -- --run=free

