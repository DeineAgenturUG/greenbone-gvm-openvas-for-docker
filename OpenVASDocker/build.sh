#!/bin/bash
set -e
echo "Acquire::http::Proxy \"${http_proxy}\";" >> /etc/apt/apt.conf.d/30proxy
echo "APT::Install-Recommends \"0\" ; APT::Install-Suggests \"0\" ;" >> /etc/apt/apt.conf.d/10no-recommend-installs
apt-get update -q
apt-get install -yq --no-install-recommends \
  apt-utils \
  coreutils \
  ca-certificates \
  gnupg \
  sudo \
  rsync \
  wget \
  lsb-release \
  curl
echo "/usr/local/lib" | tee /etc/ld.so.conf.d/openvas.conf
ldconfig
echo 'export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"' | tee /etc/environment
sed -i '7c\ \ PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"' /etc/profile

echo "deb http://deb.debian.org/debian $(lsb_release -cs)-backports main" | tee /etc/apt/sources.list.d/backports.list
apt-get update -q
ls /opt/context/

{ cat <<EOF
autossh
bison
ca-certificates
curl
gnupg-utils
gnutls-bin
gpg
heimdal-multidev
ike-scan
libglib2.0-0
libgnutls30
libgpgme11
libhiredis0.14
libjson-glib-1.0-0
libldap-2.4-2
libnet1
libp11-kit0
libpaho-mqtt1.3
libpcap0.8/bullseye-backports
libpcre3
libradcli4
libssh-gcrypt-4
libuuid1
libxml2
net-tools
nmap
snmp
netdiag
pnscan
iputils-ping
dsniff
ldap-utils
net-tools
openssh-client
python3
python3-cffi
python3-defusedxml
python3-deprecated
python3-impacket
python3-lxml
python3-packaging
python3-paho-mqtt
python3-paramiko
python3-pip
python3-psutil
python3-redis
python3-setuptools
python3-wrapt
python3-pip
redis/bullseye-backports
rsync
smbclient
supervisor
wapiti
wget
xz-utils
EOF
} | xargs apt-get install -yq --no-install-recommends

{
  echo "/usr/local/lib";
  echo "/usr/lib";
} >/etc/ld.so.conf.d/openvas.conf
ldconfig

find / -name '*libopenvas_wmiclient*'

python3 -m pip install --upgrade "ospd_openvas==${OSPD_OPENVAS_VERSION}"
python3 -m pip install --upgrade "gvm-tools==${GVM_TOOLS_VERSION}"
python3 -m pip install --upgrade "python-gvm==${PYTHON_GVM_VERSION}"


useradd -r -M -d /var/lib/gvm -U -G sudo -s /bin/bash gvm
usermod -aG tty gvm
usermod -aG sudo gvm
usermod -aG gvm redis
mkdir -p /run/redis
chown redis:gvm /run/redis
mkdir -p /run/gvmd
mkdir -p /var/lib/gvm
mkdir -p /var/log/gvm
chgrp -R gvm /etc/openvas/
mkdir -p /var/lib/openvas/plugins
chown -R gvm:gvm /var/lib/openvas/
chown -R gvm:gvm /run/gvmd
chown -R gvm:gvm /var/lib/gvm
chown -R gvm:gvm /var/log/gvm

ls -lahr /opt/context/

mkdir -p /opt/setup/scripts
cp -a /opt/context/scripts/. /opt/setup/scripts/
wget -O /opt/setup/nvt-feed.tar.xz https://vulndata.deineagentur.biz/nvt-feed.tar.xz

echo "gvm ALL = NOPASSWD: /usr/sbin/openvas" > /etc/sudoers.d/gvm
chmod 0440 /etc/sudoers.d/gvm

cp /opt/context/config/supervisord.conf /etc/supervisord.conf
cp /opt/context/config/redis-openvas.conf /etc/redis.conf
apt-get remove -y --purge python3-pip libxml2-dev libxslt-dev gcc python3-dev
apt-get autoremove -y
rm -rf /var/lib/apt/lists/*
