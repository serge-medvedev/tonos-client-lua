FROM debian:buster-slim

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

RUN curl -L -o /tmp/api.json https://raw.githubusercontent.com/tonlabs/TON-SDK/1.0.0/tools/api.json \
    && curl -L -o /usr/include/tonclient.h https://raw.githubusercontent.com/tonlabs/TON-SDK/1.0.0/ton_client/client/tonclient.h \
    && curl -L -o tonclient.gz http://sdkbinaries-ws.tonlabs.io/tonclient_1_0_0_linux.gz \
    && gunzip tonclient.gz \
    && mv tonclient /usr/lib/libton_client.so

RUN luarocks install dkjson \
    && luarocks install lustache

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

