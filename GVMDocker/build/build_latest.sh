#!/usr/bin/env bash
set -Eeuo pipefail

HTTP_PROXY=${HTTP_PROXY:-${http_proxy:-}}
HTTPS_PROXY=${HTTPS_PROXY:-${https_proxy:-}}


if [[ -n "${HTTP_PROXY}" ]]; then
  touch /etc/apt/apt.conf.d/99proxy
  {
    echo "Acquire::http::Proxy \"${HTTP_PROXY}\";"
  } > /etc/apt/apt.conf.d/99proxy
fi
if [[ -n "${HTTPS_PROXY}" ]]; then
  touch /etc/apt/apt.conf.d/99proxy
  {
    echo "Acquire::http::Proxy \"${HTTP_PROXY}\";"
  } >> /etc/apt/apt.conf.d/99proxy
fi

echo "APT::Install-Recommends \"0\" ; APT::Install-Suggests \"0\" ;" > /etc/apt/apt.conf.d/10no-recommend-installs


echo "/usr/local/lib" >/etc/ld.so.conf.d/openvas.conf
echo 'export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"'>>/etc/environment
sed -i '7c\ \ PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"' /etc/profile
ldconfig
chmod -R +x /opt/setup/scripts/*.sh

apt-get update
apt-get install -y --no-install-recommends \
        apt-utils \
        coreutils \
        ca-certificates \
        gnupg \
        sudo \
        rsyslog \
        logrotate \
        rsync \
        wget \
        lsb-release \
        curl
{
  echo "deb https://deb.debian.org/debian bullseye main"
  echo "deb https://security.debian.org/debian-security bullseye-security main"
  echo "deb https://deb.debian.org/debian bullseye-updates main"
  echo "deb https://apt.postgresql.org/pub/repos/apt/ bullseye-pgdg main"
  echo "deb https://deb.debian.org/debian bullseye-backports main"
} > /etc/apt/sources.list
cat /opt/context/build/postgres_ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null
apt-get update
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
        "postgresql-client-${POSTGRESQL_VERSION}" locales
sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen
locale-gen
python3 -m pip install --upgrade "ospd_openvas==${OSPD_OPENVAS_VERSION}"
python3 -m pip install --upgrade "gvm-tools==${GVM_TOOLS_VERSION}"
python3 -m pip install --upgrade "python-gvm==${PYTHON_GVM_VERSION}"
useradd -r -M -d /var/lib/gvm -U -G sudo -s /bin/bash gvm
usermod -aG tty gvm
usermod -aG sudo gvm
usermod -aG gvm redis
mkdir /run/redis
chown redis:gvm /run/redis
mkdir -p /run/gvmd
mkdir -p /var/lib/gvm
mkdir -p /var/log/gvm
chgrp -R gvm /etc/openvas/
chown -R gvm:gvm /etc/gvm
chown -R gvm:gvm /run/gvmd
chown -R gvm:gvm /var/lib/gvm
chown -R gvm:gvm /var/log/gvm
mkdir -p /run/gsad
mkdir -p /var/log/gvm
chown -R gvm:gvm /run/gsad
chown -R gvm:gvm /var/log/gvm
apt-get purge --auto-remove -yq *-dev *-dev-all *-dev-"${POSTGRESQL_VERSION}"
apt-get clean all
apt-get -yq autoremove
rm -rf /var/lib/apt/lists/*
(rm /etc/apt/apt.conf.d/99proxy || true)
echo "gvm ALL = NOPASSWD: /usr/sbin/openvas" > /etc/sudoers.d/gvm
chmod 0440 /etc/sudoers.d/gvm
update-alternatives --install /usr/bin/postgres postgres /usr/lib/postgresql/${POSTGRESQL_VERSION}/bin/postgres 100
update-alternatives --install /usr/bin/initdb initdb /usr/lib/postgresql/${POSTGRESQL_VERSION}/bin/initdb 100
(rm -rfv /var/lib/gvm/CA || true)
(rm -rfv /var/lib/gvm/private || true)
(rm /etc/localtime || true)
echo "Etc/UTC" >/etc/timezone
rm -rfv /tmp/* /var/cache/apk/* /var/lib/apt/lists/*
echo "!!! FINISH Setup !!!"
