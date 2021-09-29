FROM bitnami/minideb:bullseye AS build

COPY --from=securecompliance/gvm-libs:latest /gvm /gvm/

ADD https://www.postgresql.org/media/keys/ACCC4CF8.asc /postgresql.asc

RUN apt-get update && apt-get install --no-install-recommends --assume-yes gnupg

RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt bullseye-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
    apt-key add /postgresql.asc && \
    apt-get update && \
    apt-get install --no-install-recommends --assume-yes ca-certificates curl build-essential cmake libglib2.0-dev libgnutls28-dev libpq-dev postgresql-server-dev-12 pkg-config libical-dev libgpgme-dev xsltproc xml-twig-tools libradcli4 libssh-gcrypt-4 libhiredis0.14 && \
    mkdir /build && \
    cd /build && \
    curl -L -o gvmd.tar.gz https://github.com/greenbone/gvmd/archive/refs/tags/v21.4.3.tar.gz && \
    tar -xvf gvmd.tar.gz && \
    cd gvmd-* && \
    mkdir build && \
    cd build && \
    export PKG_CONFIG_PATH=/gvm/lib/pkgconfig:$PKG_CONFIG_PATH && \
    cmake -DCMAKE_INSTALL_PREFIX=/gvm .. && \
    make install
    
FROM bitnami/minideb:bullseye

ENV LD_LIBRARY_PATH=/gvm/lib/

COPY --from=build /gvm /gvm/
COPY --from=securecompliance/openvas:latest /gvm/bin/greenbone-nvt-sync /gvm/bin/greenbone-nvt-sync

RUN apt-get update && \
    apt-get install --no-install-recommends --assume-yes libgpgme11 libpq5 libglib2.0-0 libical3 libradcli4 libssh-gcrypt-4 libhiredis0.14 libxml2 gnutls-bin xml-twig-tools texlive-latex-extra texlive-fonts-recommended xsltproc nsis wget rpm dpkg fakeroot && \
    apt-get clean && \
    useradd --home-dir /home/gvm --create-home gvmd --shell /bin/false && \
    chown gvmd:gvmd -R /gvm/var/run && \
    mkdir -p /gvm/var/log && \
    chown gvmd:gvmd -R /gvm/var/log && \
    mkdir -p /gvm/var/lib/gvm && \
    chown gvmd:gvmd -R /gvm/var/lib/gvm

COPY start.sh /start.sh
COPY dummy-script.sh /usr/bin/rsync

USER gvmd

CMD ["/start.sh"]
