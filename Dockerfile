FROM rust:1.46.0 as sdk

RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src

ENV TON_SDK_BRANCH=1.0.0-rc

RUN git clone -b $TON_SDK_BRANCH https://github.com/tonlabs/TON-SDK.git

RUN cd TON-SDK \
    && cargo update \
    && cargo build --release --manifest-path ton_client/client/Cargo.toml


FROM debian:buster

COPY --from=sdk /usr/src/TON-SDK/target/release/libton_client.so /usr/lib/
COPY --from=sdk /usr/src/TON-SDK/ton_client/client/tonclient.h /usr/include/

RUN apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates \
		build-essential \
		git \
		liblua5.1-dev \
		lua5.1 \
        wget \
        unzip

ENV LUAROCKS_VERSION=3.4.0

RUN wget https://luarocks.org/releases/luarocks-${LUAROCKS_VERSION}.tar.gz \
    && tar zxpf luarocks-${LUAROCKS_VERSION}.tar.gz \
    && cd luarocks-${LUAROCKS_VERSION} \
    && ./configure && make && make install \
    && rm -fr luarocks-${LUAROCKS_VERSION}

RUN luarocks install busted

WORKDIR /usr/src

COPY . .

RUN luarocks make \
    && luarocks test -- --pattern='.+%.spec.lua' --exclude-tags 'slow' .

ENTRYPOINT /bin/bash

