#!/usr/bin/env bash
set -Eeuo pipefail

apt-get update
apt-get -yq upgrade

#export PATH=$PATH:/usr/local/sbin
export INSTALL_PREFIX=/usr

export SOURCE_DIR=$HOME/source
mkdir -p "${SOURCE_DIR}"

export BUILD_DIR=$HOME/build
mkdir -p "${BUILD_DIR}"

export INSTALL_DIR=$HOME/install
mkdir -p "${INSTALL_DIR}"

sudo apt-get install --no-install-recommends --assume-yes \
    build-essential \
    curl \
    cmake \
    pkg-config \
    python3 \
    python3-dev \
    python3-pip \
    gnupg \
    supervisor
sudo python3 -m pip install --upgrade pip

curl -O https://www.greenbone.net/GBCommunitySigningKey.asc
gpg --import <GBCommunitySigningKey.asc
(
    echo 5
    echo y
    echo save
) | gpg --command-fd 0 --no-tty --no-greeting -q --edit-key "$(gpg --list-packets <GBCommunitySigningKey.asc | awk '$1=="keyid:"{print$2;exit}')" trust

# Install required dependencies for gvm-libs
sudo apt-get install -y --no-install-recommends \
    libglib2.0-dev \
    graphviz \
    graphviz-dev \
    libgpgme-dev \
    libgpgme11 \
    libgnutls28-dev \
    uuid-dev \
    libssh-gcrypt-dev \
    libssh-gcrypt-4 \
    libhiredis-dev \
    libhiredis0.14 \
    libxml2-dev \
    libpcap-dev \
    libnet1-dev \
    libnet1

# Install optional dependencies for gvm-libs
sudo apt-get install -y --no-install-recommends \
    libldap2-dev \
    libradcli-dev \
    libradcli4

# Download and install gvm-libs
curl -sSL "https://github.com/greenbone/gvm-libs/archive/refs/tags/v${GVM_LIBS_VERSION}.tar.gz" -o "${SOURCE_DIR}/gvm-libs-${GVM_LIBS_VERSION}.tar.gz"
curl -sSL "https://github.com/greenbone/gvm-libs/releases/download/v${GVM_LIBS_VERSION}/gvm-libs-${GVM_LIBS_VERSION}.tar.gz.asc" -o "${SOURCE_DIR}/gvm-libs-${GVM_LIBS_VERSION}.tar.gz.asc"

ls -lahr "${SOURCE_DIR}"

# Verify the signature of the gvm-libs tarball
gpg --verify "${SOURCE_DIR}/gvm-libs-${GVM_LIBS_VERSION}.tar.gz.asc" "${SOURCE_DIR}/gvm-libs-${GVM_LIBS_VERSION}.tar.gz"

# Unpack the gvm-libs tarball
tar -C "${SOURCE_DIR}" -xvzf "${SOURCE_DIR}/gvm-libs-${GVM_LIBS_VERSION}.tar.gz"

# Build and install gvm-libs

mkdir -p "${BUILD_DIR}/gvm-libs" && cd "${BUILD_DIR}/gvm-libs"

cmake "${SOURCE_DIR}/gvm-libs-${GVM_LIBS_VERSION}" \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DSYSCONFDIR=/etc \
    -DLOCALSTATEDIR=/var

make "-j$(nproc)"

make DESTDIR="${INSTALL_DIR}" install
sudo cp -rv ${INSTALL_DIR}/* /
#rm -rf ${INSTALL_DIR}/*

# Install required dependencies for gvmd
sudo apt-get install -y --no-install-recommends \
    libglib2.0-dev \
    libgnutls28-dev \
    libpq-dev \
    postgresql-server-dev-${POSTGRESQL_VERSION:-all} \
    libical-dev \
    libical3 \
    xsltproc \
    rsync

# Install optional dependencies for gvmd
sudo apt-get install -y --no-install-recommends \
    xmlstarlet \
    zip \
    rpm \
    fakeroot \
    dpkg \
    nsis \
    gnupg \
    gpgsm \
    wget \
    sshpass \
    openssh-client \
    socat \
    snmp \
    python3 \
    smbclient \
    python3-lxml \
    gnutls-bin \
    xml-twig-tools

# Download and install gvmd
curl -sSL https://github.com/greenbone/gvmd/archive/refs/tags/v${GVMD_VERSION}.tar.gz -o ${SOURCE_DIR}/gvmd-${GVMD_VERSION}.tar.gz
curl -sSL https://github.com/greenbone/gvmd/releases/download/v${GVMD_VERSION}/gvmd-${GVMD_VERSION}.tar.gz.asc -o ${SOURCE_DIR}/gvmd-${GVMD_VERSION}.tar.gz.asc

gpg --verify ${SOURCE_DIR}/gvmd-${GVMD_VERSION}.tar.gz.asc ${SOURCE_DIR}/gvmd-${GVMD_VERSION}.tar.gz

tar -C ${SOURCE_DIR} -xvzf ${SOURCE_DIR}/gvmd-${GVMD_VERSION}.tar.gz

mkdir -p ${BUILD_DIR}/gvmd && cd ${BUILD_DIR}/gvmd

cmake ${SOURCE_DIR}/gvmd-${GVMD_VERSION} \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DLOCALSTATEDIR=/var \
    -DSYSCONFDIR=/etc \
    -DGVM_DATA_DIR=/var \
    -DPostgreSQL_TYPE_INCLUDE_DIR=/usr/include/postgresql \
    -DOPENVAS_DEFAULT_SOCKET=/run/ospd/ospd-openvas.sock \
    -DGVM_FEED_LOCK_PATH=/var/lib/gvm/feed-update.lock \
    -DSYSTEMD_SERVICE_DIR=/lib/systemd/system \
    -DDEFAULT_CONFIG_DIR=/etc/default \
    -DLOGROTATE_DIR=/etc/logrotate.d

make -j$(nproc)

make DESTDIR=${INSTALL_DIR} install
sudo cp -rv ${INSTALL_DIR}/* /
#rm -rf ${INSTALL_DIR}/*

# Install required dependencies for gsad & gsa
sudo apt-get install -y --no-install-recommends \
    libmicrohttpd-dev \
    libmicrohttpd12 \
    libxml2-dev \
    libglib2.0-dev \
    libgnutls28-dev

sudo apt-get install -y --no-install-recommends \
    nodejs \
    yarnpkg

# looks like need because of an issue with yarn
yarnpkg install
yarnpkg upgrade

curl -sSL https://github.com/greenbone/gsa/archive/refs/tags/v${GSA_VERSION}.tar.gz -o ${SOURCE_DIR}/gsa-${GSA_VERSION}.tar.gz
curl -sSL https://github.com/greenbone/gsa/releases/download/v${GSA_VERSION}/gsa-${GSA_VERSION}.tar.gz.asc -o ${SOURCE_DIR}/gsa-${GSA_VERSION}.tar.gz.asc
gpg --verify ${SOURCE_DIR}/gsa-${GSA_VERSION}.tar.gz.asc ${SOURCE_DIR}/gsa-${GSA_VERSION}.tar.gz
tar -C ${SOURCE_DIR} -xvzf ${SOURCE_DIR}/gsa-${GSA_VERSION}.tar.gz

#curl -sSL https://github.com/greenbone/gsa/releases/download/v${GSA_VERSION}/gsa-node-modules-${GSA_VERSION}.tar.gz -o ${SOURCE_DIR}/gsa-node-modules-${GSA_VERSION}.tar.gz
#curl -sSL https://github.com/greenbone/gsa/releases/download/v${GSA_VERSION}/gsa-node-modules-${GSA_VERSION}.tar.gz.asc -o ${SOURCE_DIR}/gsa-node-modules-${GSA_VERSION}.tar.gz.asc
#gpg --verify ${SOURCE_DIR}/gsa-node-modules-${GSA_VERSION}.tar.gz.asc ${SOURCE_DIR}/gsa-node-modules-${GSA_VERSION}.tar.gz
#tar -C ${SOURCE_DIR}/gsa-${GSA_VERSION}/gsa -xvzf ${SOURCE_DIR}/gsa-node-modules-${GSA_VERSION}.tar.gz

mkdir -p ${SOURCE_DIR}/gsa-${GSA_VERSION} && cd $_

yarnpkg
yarnpkg build

mkdir -p $INSTALL_PREFIX/share/gvm/gsad/web/
cp -r build/* $INSTALL_PREFIX/share/gvm/gsad/web/

# download gsad

curl -sSL https://github.com/greenbone/gsad/archive/refs/tags/v${GSAD_VERSION}.tar.gz -o ${SOURCE_DIR}/gsad-${GSAD_VERSION}.tar.gz
curl -sSL https://github.com/greenbone/gsad/releases/download/v${GSAD_VERSION}/gsad-${GSAD_VERSION}.tar.gz.asc -o ${SOURCE_DIR}/gsad-${GSAD_VERSION}.tar.gz.asc
gpg --verify ${SOURCE_DIR}/gsad-${GSAD_VERSION}.tar.gz.asc ${SOURCE_DIR}/gsad-${GSAD_VERSION}.tar.gz
tar -C ${SOURCE_DIR} -xvzf ${SOURCE_DIR}/gsad-${GSAD_VERSION}.tar.gz

mkdir -p ${BUILD_DIR}/gsad && cd $_

cmake ${SOURCE_DIR}/gsad-${GSAD_VERSION} \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DSYSCONFDIR=/etc \
    -DLOCALSTATEDIR=/var \
    -DLOGROTATE_DIR=/etc/logrotate.d \
    -DGVMD_RUN_DIR=/run/gvmd \
    -DGSAD_RUN_DIR=/run/gsad \
    -DGSAD_PID_DIR=/run/gsad

make DESTDIR=${INSTALL_DIR} install
sudo cp -rv ${INSTALL_DIR}/* /
#rm -rf ${INSTALL_DIR}/*
yarnpkg cache clean

sudo apt-get purge -y \
    nodejs \
    yarnpkg

# Install required dependencies for openvas-smb
#
#if [[ "$(dpkg --print-architecture)" == "amd64" ]]; then
#
#  sudo apt-get install -y --no-install-recommends \
#      gcc-mingw-w64 \
#      libgnutls28-dev \
#      libglib2.0-dev \
#      libpopt-dev \
#      libunistring-dev \
#      heimdal-dev \
#      libgssapi3-heimdal \
#      libhdb9-heimdal \
#      perl-base
#
#  curl -sSL https://github.com/greenbone/openvas-smb/archive/refs/tags/v${OPENVAS_SMB_VERSION}.tar.gz -o ${SOURCE_DIR}/openvas-smb-${OPENVAS_SMB_VERSION}.tar.gz
#  curl -sSL https://github.com/greenbone/openvas-smb/releases/download/v${OPENVAS_SMB_VERSION}/openvas-smb-${OPENVAS_SMB_VERSION}.tar.gz.asc -o ${SOURCE_DIR}/openvas-smb-${OPENVAS_SMB_VERSION}.tar.gz.asc
#
#  gpg --verify ${SOURCE_DIR}/openvas-smb-${OPENVAS_SMB_VERSION}.tar.gz.asc ${SOURCE_DIR}/openvas-smb-${OPENVAS_SMB_VERSION}.tar.gz
#
#  tar -C ${SOURCE_DIR} -xvzf ${SOURCE_DIR}/openvas-smb-${OPENVAS_SMB_VERSION}.tar.gz
#
#  mkdir -p ${BUILD_DIR}/openvas-smb && cd ${BUILD_DIR}/openvas-smb
#
#  cmake ${SOURCE_DIR}/openvas-smb-${OPENVAS_SMB_VERSION} \
#      -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
#      -DCMAKE_BUILD_TYPE=Release
#
#  make -j$(nproc)
#  make DESTDIR=${INSTALL_DIR} install
#  sudo cp -rv ${INSTALL_DIR}/* /
#  #rm -rf ${INSTALL_DIR}/*
#
#fi

# Install required dependencies for openvas-scanner
sudo apt-get install -y --no-install-recommends \
    bison \
    libglib2.0-dev \
    libgnutls28-dev \
    libgcrypt20-dev \
    libpcap-dev \
    libgpgme-dev \
    libksba-dev \
    rsync \
    nmap

# Install optional dependencies for openvas-scanner
sudo apt-get install -y \
    python3-impacket \
    libsnmp-dev

curl -sSL https://github.com/greenbone/openvas-scanner/archive/refs/tags/v${OPENVAS_SCANNER_VERSION}.tar.gz -o ${SOURCE_DIR}/openvas-scanner-${OPENVAS_SCANNER_VERSION}.tar.gz
curl -sSL https://github.com/greenbone/openvas-scanner/releases/download/v${OPENVAS_SCANNER_VERSION}/openvas-scanner-${OPENVAS_SCANNER_VERSION}.tar.gz.asc -o ${SOURCE_DIR}/openvas-scanner-${OPENVAS_SCANNER_VERSION}.tar.gz.asc
gpg --verify ${SOURCE_DIR}/openvas-scanner-${OPENVAS_SCANNER_VERSION}.tar.gz.asc ${SOURCE_DIR}/openvas-scanner-${OPENVAS_SCANNER_VERSION}.tar.gz

tar -C ${SOURCE_DIR} -xvzf ${SOURCE_DIR}/openvas-scanner-${OPENVAS_SCANNER_VERSION}.tar.gz

mkdir -p ${BUILD_DIR}/openvas-scanner && cd ${BUILD_DIR}/openvas-scanner

cmake ${SOURCE_DIR}/openvas-scanner-${OPENVAS_SCANNER_VERSION} \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DSYSCONFDIR=/etc \
    -DLOCALSTATEDIR=/var \
    -DOPENVAS_FEED_LOCK_PATH=/var/lib/openvas/feed-update.lock \
    -DOPENVAS_RUN_DIR=/run/ospd

make -j$(nproc)
make DESTDIR=${INSTALL_DIR} install
sudo cp -rv ${INSTALL_DIR}/* /
#rm -rf ${INSTALL_DIR}/*

# Install required dependencies for ospd-openvas
sudo apt-get install -y --no-install-recommends \
    python3.9 \
    python3-pip \
    python3-setuptools \
    python3-packaging \
    python3-paho-mqtt \
    python3-wrapt \
    python3-cffi \
    python3-psutil \
    python3-deprecated \
    python3-lxml \
    python3-defusedxml \
    python3-paramiko \
    python3-redis \
    libnet1

sudo python3 -m pip install --upgrade setuptools

#sudo python3 -m pip install --no-warn-script-location psutil

# Download and install ospd-openvas

curl -sSL https://github.com/greenbone/ospd-openvas/archive/refs/tags/v${OSPD_OPENVAS_VERSION}.tar.gz -o ${SOURCE_DIR}/ospd-openvas-${OSPD_OPENVAS_VERSION}.tar.gz
curl -sSL https://github.com/greenbone/ospd-openvas/releases/download/v${OSPD_OPENVAS_VERSION}/ospd-openvas-${OSPD_OPENVAS_VERSION}.tar.gz.asc -o ${SOURCE_DIR}/ospd-openvas-${OSPD_OPENVAS_VERSION}.tar.gz.asc
gpg --verify ${SOURCE_DIR}/ospd-openvas-${OSPD_OPENVAS_VERSION}.tar.gz.asc ${SOURCE_DIR}/ospd-openvas-${OSPD_OPENVAS_VERSION}.tar.gz

tar -C ${SOURCE_DIR} -xvzf ${SOURCE_DIR}/ospd-openvas-${OSPD_OPENVAS_VERSION}.tar.gz

cd ${SOURCE_DIR}/ospd-openvas-${OSPD_OPENVAS_VERSION}
python3 -m pip install . --prefix=${INSTALL_PREFIX} --root=${INSTALL_DIR} --no-warn-script-location
python3 -m pip install . --no-warn-script-location
sudo cp -rv ${INSTALL_DIR}/* /
#rm -rf ${INSTALL_DIR}/*

# Install required dependencies for gvmd-tools
sudo apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-packaging \
    python3-lxml \
    python3-defusedxml \
    python3-paramiko
sudo python3 -m pip install --upgrade setuptools
# Install for user
# python3 -m pip install --user gvm-tools

# Install for root
python3 -m pip install --no-warn-script-location gvm-tools
python3 -m pip install --prefix=${INSTALL_PREFIX} --root=${INSTALL_DIR} --no-warn-script-location gvm-tools
sudo cp -rv ${INSTALL_DIR}/* /
#rm -rf ${INSTALL_DIR}/*

# Install redis-server
sudo apt-get install -y --no-install-recommends redis-server/bullseye-backports
sudo mkdir -p /etc/redis
sudo cp ${SOURCE_DIR}/openvas-scanner-${OPENVAS_SCANNER_VERSION}/config/redis-openvas.conf /etc/redis/redis-openvas.conf
sudo chown redis:redis /etc/redis/*.conf
echo "db_address = /run/redis/redis.sock" | sudo tee -a /etc/openvas/openvas.conf

sudo usermod -aG redis gvm

# Adjusting the permissions
sudo chown -R gvm:gvm /var/lib/gvm
sudo chown -R gvm:gvm /var/lib/openvas
sudo chown -R gvm:gvm /var/log/gvm
sudo chown -R gvm:gvm /run/gvmd
sudo chown -R gvm:gvm /run/gsad
sudo mkdir -p /run/ospd
sudo chown -R gvm:gvm /run/ospd

sudo chmod -R g+srw /var/lib/gvm
sudo chmod -R g+srw /var/lib/openvas
sudo chmod -R g+srw /var/log/gvm

sudo chown gvm:gvm /usr/sbin/gvmd
sudo chmod 6750 /usr/sbin/gvmd

sudo chown gvm:gvm /usr/bin/greenbone-nvt-sync
sudo chmod 740 /usr/sbin/greenbone-feed-sync
sudo chown gvm:gvm /usr/sbin/greenbone-*-sync
sudo chmod 740 /usr/sbin/greenbone-*-sync

# SUDO for Scanning
echo '%gvm ALL = NOPASSWD: /usr/sbin/openvas' | sudo EDITOR='tee -a' visudo

# Install Postgres
sudo apt-get install -yq --no-install-recommends "postgresql-${POSTGRESQL_VERSION:-all}"

# Remove required dependencies for gvm-libs
sudo apt-get purge --auto-remove -y \
    heimdal-dev \
    libgcrypt20-dev \
    libglib2.0-dev \
    libgnutls28-dev \
    libgpgme-dev \
    libhiredis-dev \
    libksba-dev \
    libldap2-dev \
    libmicrohttpd-dev \
    libnet1-dev \
    libpcap-dev \
    libpopt-dev \
    libradcli-dev \
    libsnmp-dev \
    libssh-gcrypt-dev \
    libunistring-dev \
    libxml2-dev \
    uuid-dev \
    python3-dev \
    build-essential \
    postgresql-server-dev-${POSTGRESQL_VERSION:-all} \
    nodejs \
    yarnpkg \
    graphviz-dev \
    cmake
sudo apt-get purge --auto-remove -yq *-dev *-dev-"${POSTGRESQL_VERSION:-all}"
sudo apt-get clean all
sudo apt-get -yq autoremove
sudo apt-get clean all
echo "/usr/local/lib" >/etc/ld.so.conf.d/openvas.conf && ldconfig

rm -rf ${SOURCE_DIR} ${BUILD_DIR} ${INSTALL_DIR}
rm -rf /var/lib/apt/lists/*
rm /etc/apt/apt.conf.d/30proxy || true
