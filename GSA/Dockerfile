FROM bitnami/minideb:bullseye AS build

COPY --from=securecompliance/gvm-libs:latest /gvm /gvm/

RUN apt-get update && \
    apt-get install --no-install-recommends --assume-yes ca-certificates curl && \
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install --no-install-recommends --assume-yes ca-certificates curl build-essential pkg-config cmake libmicrohttpd-dev libxml2-dev libglib2.0-dev nodejs libgpgme11 libradcli4 libssh-gcrypt-4 libhiredis0.14 libgcrypt20-dev && \
    npm install -g yarn && \
    mkdir /build && \
    cd /build && \
    curl -L -o gsa.tar.gz https://github.com/greenbone/gsa/archive/refs/tags/v21.4.2.tar.gz && \
    tar -xvf gsa.tar.gz && \
    cd gsa-* && \
    mkdir build && \
    cd build && \
    export PKG_CONFIG_PATH=/gvm/lib/pkgconfig:$PKG_CONFIG_PATH && \
    cmake -DCMAKE_INSTALL_PREFIX=/gvm .. && \
    make install
    
FROM bitnami/minideb:bullseye

ENV LD_LIBRARY_PATH=/gvm/lib/

COPY --from=build /gvm /gvm/

RUN apt-get update && \
    apt-get install --no-install-recommends --assume-yes libmicrohttpd12 libglib2.0-0 libxml2 libgpgme11 libradcli4 libssh-gcrypt-4 libhiredis0.14 && \
    useradd --home-dir /home/gsad --create-home gsad --shell /bin/false && \
    chown gsad:gsad -R /gvm/var/run

USER gsad

CMD ["/gvm/sbin/gsad", "--foreground", "--listen=::", "--port=9392", "--munix-socket=/gvm/var/run/gvmd.sock", "--gnutls-priorities=SECURE128:-AES-128-CBC:-CAMELLIA-128-CBC:-VERS-SSL3.0:-VERS-TLS1.0"]
