FROM ubuntu:20.04

RUN apt-get update && apt-get install --no-install-recommends -y \
    ca-certificates \
    build-essential \
    git \
    liblua5.1-dev \
    lua5.1 \
    zip \
    unzip \
    gzip \
    curl

ENV LUAROCKS_VERSION=3.4.0

RUN curl -LO https://luarocks.org/releases/luarocks-${LUAROCKS_VERSION}.tar.gz \
    && tar zxpf luarocks-${LUAROCKS_VERSION}.tar.gz \
    && cd luarocks-${LUAROCKS_VERSION} \
    && ./configure && make && make install \
    && rm -fr luarocks-${LUAROCKS_VERSION}

RUN curl -L -o /tmp/api.json https://raw.githubusercontent.com/tonlabs/TON-SDK/1.21.4/tools/api.json \
    && curl -L -o /usr/include/tonclient.h https://raw.githubusercontent.com/tonlabs/TON-SDK/1.21.4/ton_client/tonclient.h \
    && curl -L -o /usr/lib/libton_client.so.gz http://sdkbinaries-ws.tonlabs.io/tonclient_1_21_4_linux.gz \
    && gunzip /usr/lib/libton_client.so.gz

RUN luarocks install dkjson \
    && luarocks install lustache \
    && luarocks install busted \
    && luarocks install --deps-mode=none lumen

WORKDIR /usr/src

COPY . .

RUN tools/codegen.lua /tmp/api.json

RUN luarocks make \
    && luarocks show tonos-client \
    && luarocks test

