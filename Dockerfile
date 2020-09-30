FROM rust:1.46.0 as sdk

RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src

ENV TON_SDK_BRANCH=1.0.0-rc

RUN git clone -b $TON_SDK_BRANCH https://github.com/tonlabs/TON-SDK.git

RUN cd TON-SDK \
    && cargo build --release --manifest-path ton_client/client/Cargo.toml


FROM debian:buster

RUN apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates \
		build-essential \
		git \
		libffcall-dev \
		liblua5.1-dev \
		lua5.1 \
		luarocks \
    && luarocks install busted

COPY --from=sdk /usr/src/TON-SDK/target/release/libton_client.so /usr/lib/
COPY --from=sdk /usr/src/TON-SDK/ton_client/client/tonclient.h /usr/include/

WORKDIR /usr/src

COPY . .

RUN make rock test

ENTRYPOINT /bin/bash

