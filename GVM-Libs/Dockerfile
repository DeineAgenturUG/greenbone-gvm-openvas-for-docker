FROM bitnami/minideb:bullseye AS build

RUN apt-get update && \
    apt-get install --no-install-recommends --assume-yes ca-certificates curl build-essential cmake pkg-config libglib2.0-dev libgpgme-dev libgnutls28-dev uuid-dev libssh-gcrypt-dev libhiredis-dev libxml2-dev libpcap-dev libnet1-dev libldap2-dev libradcli-dev && \
    mkdir /build && \
    mkdir /gvm && \
    cd /build && \
    curl -L -o gvm-libs.tar.gz https://github.com/greenbone/gvm-libs/archive/refs/tags/v21.4.2.tar.gz && \
    tar -xvf gvm-libs.tar.gz && \
    cd gvm-libs-* && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/gvm .. && \
    make install

FROM scratch

COPY --from=build /gvm /gvm/
