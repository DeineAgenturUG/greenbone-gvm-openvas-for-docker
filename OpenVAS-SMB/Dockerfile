FROM bitnami/minideb:bullseye AS build

RUN apt-get update && \
    apt-get install --no-install-recommends --assume-yes ca-certificates curl build-essential cmake pkg-config gcc-mingw-w64 libgnutls28-dev perl-base heimdal-dev libpopt-dev libglib2.0-dev libunistring-dev && \
    mkdir /build && \
    mkdir /gvm && \
    cd /build && \
    curl -L -o openvas-smb.tar.gz https://github.com/greenbone/openvas-smb/archive/refs/tags/v21.4.0.tar.gz && \
    tar -xvf openvas-smb.tar.gz && \
    cd openvas-smb-* && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/gvm .. && \
    make install

FROM scratch

COPY --from=build /gvm /gvm/
