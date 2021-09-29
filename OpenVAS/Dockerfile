FROM bitnami/minideb:bullseye AS build

COPY --from=securecompliance/gvm-libs:latest /gvm /gvm/
COPY --from=securecompliance/openvas-smb:latest /gvm /gvm/

ENV PYTHONPATH=/gvm/ospd/

RUN apt-get update && \
    apt-get install --no-install-recommends --assume-yes rustc cargo python3 python3-dev python3-pip python3-setuptools python3-paramiko python3-lxml python3-defusedxml ca-certificates curl build-essential cmake pkg-config libssh-gcrypt-dev libgnutls28-dev libglib2.0-dev libpcap-dev libgpgme-dev bison libksba-dev libsnmp-dev libgcrypt20-dev libradcli4 libhiredis0.14 libgssapi3-heimdal libpopt0 libheimntlm0-heimdal libkrb5-26-heimdal libhx509-5-heimdal libhcrypto4-heimdal libasn1-8-heimdal libwind0-heimdal libheimbase1-heimdal libroken18-heimdal libhdb9-heimdal libnet1

RUN mkdir /build && \
    cd /build && \
    curl -L -o openvas.tar.gz https://github.com/greenbone/openvas-scanner/archive/refs/tags/v21.4.2.tar.gz && \
    tar -xvf openvas.tar.gz && \
    cd openvas-* && \
    mkdir build && \
    cd build && \
    export PKG_CONFIG_PATH=/gvm/lib/pkgconfig:$PKG_CONFIG_PATH && \
    cmake -DCMAKE_INSTALL_PREFIX=/gvm .. && \
    make install

RUN mkdir -p /gvm/ospd
RUN pip3 install --upgrade --target=/gvm/ospd ospd==21.4.3
RUN pip3 install --upgrade --target=/gvm/ospd ospd-openvas==21.4.2

FROM bitnami/minideb:bullseye

ENV LD_LIBRARY_PATH=/gvm/lib/
ENV PYTHONPATH=/gvm/ospd/
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/gvm/sbin

COPY --from=build /gvm /gvm/

RUN apt-get update && \
    apt-get install --no-install-recommends --assume-yes python3-paramiko python3-lxml python3-defusedxml libglib2.0-0 libgpgme11 libssh-gcrypt-4 libsnmp40 libnet1 libradcli4 libhiredis0.14 libxml2 libgssapi3-heimdal libpopt0 libhdb9-heimdal libatomic1 \
        nmap python3-impacket ike-scan smbclient autossh openssh-client net-tools \
        ca-certificates curl tar xz-utils rsync && \
    apt-get clean

COPY start.sh /start.sh
COPY sync.sh /sync.sh

CMD ["/start.sh"]
