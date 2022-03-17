ARG POSTGRESQL_VERSION="13"
ARG GSAD_VERSION="21.4.4"
ARG GSA_VERSION="21.4.4"
ARG GVM_LIBS_VERSION="21.4.4"
ARG GVMD_VERSION="21.4.5"
ARG OPENVAS_SCANNER_VERSION="21.4.4"
ARG OPENVAS_SMB_VERSION="21.4.0"
ARG PYTHON_GVM_VERSION="21.11.0"
ARG OSPD_OPENVAS_VERSION="21.4.4"
ARG GVM_TOOLS_VERSION="21.10.0"


FROM debian:11-slim AS latest
ARG POSTGRESQL_VERSION
ARG GSAD_VERSION
ARG GSA_VERSION
ARG GVM_LIBS_VERSION
ARG GVMD_VERSION
ARG OPENVAS_SCANNER_VERSION
ARG OPENVAS_SMB_VERSION
ARG PYTHON_GVM_VERSION
ARG OSPD_OPENVAS_VERSION
ARG GVM_TOOLS_VERSION

ARG SETUP=0
ARG OPT_PDF=0

ARG SUPVISD=supervisorctl
ARG GVMD_USER
ARG GVMD_PASSWORD
ARG USERNAME=admin
ARG PASSWORD=adminpassword
ARG PASSWORD_FILE=none
ARG TIMEOUT=15
ARG DEBUG=N
ARG RELAYHOST=smtp
ARG SMTPPORT=25
ARG AUTO_SYNC=YES
ARG AUTO_SYNC_ON_START=YES
ARG CERTIFICATE=none
ARG CERTIFICATE_KEY=none
ARG HTTPS=true
ARG TZ=Etc/UTC
ARG SSHD=false
ARG DB_PASSWORD=none

ENV POSTGRESQL_VERSION=${POSTGRESQL_VERSION} \
    GSAD_VERSION=${GSAD_VERSION} \
    GSA_VERSION=${GSA_VERSION} \
    GVM_LIBS_VERSION=${GVM_LIBS_VERSION} \
    GVMD_VERSION=${GVMD_VERSION} \
    OPENVAS_SCANNER_VERSION=${OPENVAS_SCANNER_VERSION} \
    OPENVAS_SMB_VERSION=${OPENVAS_SMB_VERSION} \
    PYTHON_GVM_VERSION=${PYTHON_GVM_VERSION} \
    OSPD_OPENVAS_VERSION=${OSPD_OPENVAS_VERSION} \
    GVM_TOOLS_VERSION=${GVM_TOOLS_VERSION} \
    SYSTEM_DIST=debian \
    SUPVISD=${SUPVISD:-supervisorctl} \
    USERNAME=${USERNAME:-${GVMD_USER:-admin}} \
    PASSWORD=${PASSWORD:-${GVMD_PASSWORD:-admin}} \
    PASSWORD_FILE=${PASSWORD_FILE:-${GVMD_PASSWORD_FILE:-none}} \
    TIMEOUT=${TIMEOUT:-15} \
    DEBUG=${DEBUG:-N} \
    RELAYHOST=${RELAYHOST:-smtp} \
    SMTPPORT=${SMTPPORT:-25} \
    AUTO_SYNC=${AUTO_SYNC:-YES} \
    AUTO_SYNC_ON_START=${AUTO_SYNC_ON_START:-YES} \
    HTTPS=${HTTPS:-true} \
    CERTIFICATE=${CERTIFICATE:-none} \
    CERTIFICATE_KEY=${CERTIFICATE_KEY:-none} \
    TZ=${TZ:-Etc/UTC} \
    SSHD=${SSHD:-false} \
    DB_PASSWORD=${DB_PASSWORD:-none} \
    DB_PASSWORD_FILE=${DB_PASSWORD:-none} \
    DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    SETUP=${SETUP} \
    OPT_PDF=${OPT_PDF}

COPY --from=deineagenturug/gvm-build:build_gsa / /
COPY --from=deineagenturug/gvm-build:build_gsad / /
COPY --from=deineagenturug/gvm-build:build_gvm_libs / /
COPY --from=deineagenturug/gvm-build:build_gvmd / /
COPY --from=deineagenturug/gvm-build:build_openvas_smb / /
COPY --from=deineagenturug/gvm-build:build_openvas_scanner / /

ENTRYPOINT [ "/opt/setup/scripts/entrypoint.sh" ]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]

COPY config /opt/setup/config/
COPY scripts /opt/setup/scripts/

RUN echo "/usr/local/lib" >/etc/ld.so.conf.d/openvas.conf && \
    echo 'export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"'>>/etc/environment && \
    sed -i '7c\ \ PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"' /etc/profile && \
    ldconfig && \
    chmod -R +x /opt/setup/scripts/*.sh && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        apt-utils \
        coreutils \
        ca-certificates \
        gnupg \
        sudo \
        wget \
        lsb-release \
        curl && \
    echo "Acquire::http::Proxy \"${http_proxy}\";" | tee /etc/apt/apt.conf.d/30proxy && \
    echo "APT::Install-Recommends \"0\" ; APT::Install-Suggests \"0\" ;" | tee /etc/apt/apt.conf.d/10no-recommend-installs && \
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee  /etc/apt/sources.list.d/pgdg.list && \
    echo "deb http://deb.debian.org/debian `lsb_release -cs`-backports main" | tee /etc/apt/sources.list.d/backports.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        dpkg \
        fakeroot \
        gnutls-bin \
        gosu \
        gpgsm \
        libglib2.0-0 \
        libgnutls30 \
        libgpgme11 \
        libhiredis0.14 \
        libical3 \
        libgssapi3-heimdal \
        libhdb9-heimdal \
        libldap-2.4-2 \
        libmicrohttpd12 \
        libnet1 \
        libpaho-mqtt1.3 \
        libpcap0.8 \
        libpq5 \
        libradcli4 \
        libssh-gcrypt-4 \
        libuuid1 \
        libxml2 \
        openssh-client \
        postfix \
        python3 \
        python3-cffi \
        python3-defusedxml \
        python3-deprecated \
        python3-impacket \
        python3-lxml \
        python3-packaging \
        python3-paho-mqtt \
        python3-paramiko \
        python3-pip \
        python3-psutil \
        python3-redis \
        python3-setuptools \
        python3-wrapt \
        redis/bullseye-backports \
        rpm \
        smbclient \
        snmp \
        socat \
        sshpass \
        sudo \
        supervisor \
        xml-twig-tools \
        xmlstarlet \
        xsltproc \
        zip  \
        cron openssh-server nano \
        xz-utils \
        "postgresql-${POSTGRESQL_VERSION}" \
        "postgresql-common" \
        "postgresql-client-${POSTGRESQL_VERSION}" locales && \
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen && \
    python3 -m pip install --upgrade "ospd_openvas==${OSPD_OPENVAS_VERSION}" && \
    python3 -m pip install --upgrade "gvm-tools==${GVM_TOOLS_VERSION}" && \
    python3 -m pip install --upgrade "python-gvm==${PYTHON_GVM_VERSION}" && \
    useradd -r -M -d /var/lib/gvm -U -G sudo -s /bin/bash gvm && \
    usermod -aG tty gvm  && \
    usermod -aG sudo gvm && \
    usermod -aG gvm redis && \
    mkdir /run/redis && \
    chown redis:gvm /run/redis && \
    mkdir -p /run/gvmd && \
    mkdir -p /var/lib/gvm && \
    mkdir -p /var/log/gvm && \
    chgrp -R gvm /etc/openvas/ && \
    chown -R gvm:gvm /etc/gvm && \
    chown -R gvm:gvm /run/gvmd && \
    chown -R gvm:gvm /var/lib/gvm && \
    chown -R gvm:gvm /var/log/gvm && \
    mkdir -p /run/gsad && \
    mkdir -p /var/log/gvm && \
    chown -R gvm:gvm /run/gsad && \
    chown -R gvm:gvm /var/log/gvm && \
    apt-get purge --auto-remove -yq *-dev *-dev-all *-dev-"${POSTGRESQL_VERSION}" && \
    apt-get clean all && \
    apt-get -yq autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    (rm /etc/apt/apt.conf.d/30proxy || true)
RUN update-alternatives --install /usr/bin/postgres postgres /usr/lib/postgresql/${POSTGRESQL_VERSION}/bin/postgres 100 && \
    update-alternatives --install /usr/bin/initdb initdb /usr/lib/postgresql/${POSTGRESQL_VERSION}/bin/initdb 100
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN set -eu; \
    rm -rfv /var/lib/gvm/CA || true \
    && rm -rfv /var/lib/gvm/private || true \
    && rm /etc/localtime || true\
    && echo "Etc/UTC" >/etc/timezone \
    && rm -rfv /tmp/* /var/cache/apk/* /var/lib/apt/lists/* \
    && echo "!!! FINISH Setup !!!"

VOLUME [ "/var/lib/gvm" ]
