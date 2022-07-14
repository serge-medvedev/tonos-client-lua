FROM ubuntu:20.04

RUN apt-get update && apt-get install --no-install-recommends -y \
    ca-certificates \
    build-essential \
    git \
    liblua5.1-dev \
    lua5.1 \
    unzip \
    gzip \
    wget

ENV LUAROCKS_VERSION=3.4.0

RUN wget https://luarocks.org/releases/luarocks-${LUAROCKS_VERSION}.tar.gz \
    && tar zxpf luarocks-${LUAROCKS_VERSION}.tar.gz \
    && cd luarocks-${LUAROCKS_VERSION} \
    && ./configure && make && make install \
    && rm -fr luarocks-${LUAROCKS_VERSION}

RUN wget https://raw.githubusercontent.com/tonlabs/TON-SDK/1.36.0/ton_client/tonclient.h -O /usr/include/tonclient.h \
    && wget http://sdkbinaries-ws.tonlabs.io/tonclient_1_36_0_linux.gz -O /usr/lib/libton_client.so.gz \
    && gunzip /usr/lib/libton_client.so.gz

RUN luarocks install tonos-client

WORKDIR /usr/src

COPY . .

CMD ./example.lua

