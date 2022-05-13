#!/usr/bin/env bash
set -eo pipefail

# TODO: create own public repo with the custom build postgres deb files.
architecture=$(dpkg --print-architecture)
if [ "x${architecture}" != "xamd64" ] && [ "x${architecture}" != "xarm64" ] && [ "x${architecture}" != "xppc64el" ]; then
  echo "Your System architecture (${architecture}) is unsupported, please use an architecture of amd64, arm64 or ppc64el."
  echo "Currently we have no public apt repository to support all architecture of this image."
  [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

DELETE_OLD="${DELETE_OLD:-FALSE}"
PG_OLD_VERSION="0" # override after path check
PG_OLD_DATA_PATH="/mnt/pg_old/data/"
PG_OLD_TEMP_DATA_PATH="/work/old_pg_data/"
PG_OLD_BIN_PATH="/usr/lib/postgresql/${PG_OLD_VERSION}/bin"
PG_NEW_VERSION="13"
PG_NEW_DATA_PATH="/mnt/pg_new/data/"
PG_NEW_BIN_PATH="/usr/lib/postgresql/${PG_NEW_VERSION}/bin"

if [[ ! -d "${PG_OLD_DATA_PATH}" ]]; then
  echo "You have not mount the OLD Database Storage Path to '${PG_OLD_DATA_PATH}'."
  [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi
if [[ ! -d "${PG_NEW_DATA_PATH}" ]]; then
  echo "You have not mount the NEW Database Storage Path to '${PG_NEW_DATA_PATH}'."
  [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

PG_OLD_VERSION="$(sudo cat /mnt/pg_old/data/PG_VERSION)"
if [[ "x${PG_OLD_VERSION}" == "x${PG_NEW_VERSION}" ]]; then
  echo "No Upgrade need for Source Database - it already on Version ${PG_NEW_VERSION}."
  [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

mkdir -p /work
chmod 0777 /work
cd /work


apt-get update
apt-get install -y --no-install-recommends \
        dpkg zip nano xz-utils locales \
        libglib2.0-0 libical3 libgnutls30 libgpgme11 libradcli4 libldap-2.4-2 \
        libssh-gcrypt-4 libuuid1 libxml2 libhiredis0.14 libpcap0.8 libnet1 \
        "postgresql-common" "libpq-dev"\
        "postgresql-${PG_OLD_VERSION}" "postgresql-client-${PG_OLD_VERSION}" "postgresql-server-dev-${PG_OLD_VERSION}" "postgresql-contrib-${PG_OLD_VERSION}"
sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen
locale-gen
rm -rfv /tmp/* /var/cache/apk/* /var/lib/apt/lists/*


if [[ ! -f "${PG_OLD_BIN_PATH}/pg_upgrade" ]]; then
  echo "The Source Database Version (${PG_OLD_VERSION}) is not supported."
  [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi
if [[ ! -f "${PG_NEW_BIN_PATH}/pg_upgrade" ]]; then
  echo "The Destination Database (${PG_NEW_VERSION}) is not supported."
  [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

NEW_UID=$(sudo -u postgres id -u)
NEW_GID=$(sudo -u postgres id -g)

OLD_UID=$(stat -c '%u' /mnt/pg_old/data/PG_VERSION)
OLD_GID=$(stat -c '%g' /mnt/pg_old/data/PG_VERSION)

if [[ "x$(find ${PG_NEW_DATA_PATH} -maxdepth 0 -empty)" != "x${PG_NEW_DATA_PATH}" ]]; then
  read -p "The Volume of the new Version is not empty, should we delete all data in it? Please type 'Y' to continue..." -n 1 -r
  echo    # (optional) move to a new line
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
  else
    rm -rf ${PG_NEW_DATA_PATH}{..?*,.[!.]*,*} 2>/dev/null
  fi
fi

echo "Copy old PG_DATA and chown to process user"
mkdir -p "${PG_OLD_TEMP_DATA_PATH}" || true
rsync -az "--chown=${NEW_UID}:${NEW_GID}" "${PG_OLD_DATA_PATH}" "${PG_OLD_TEMP_DATA_PATH}"
rm "${PG_OLD_TEMP_DATA_PATH}postmaster.pid" || true

# OLD SERVER DATA PORT CHANGE
sed -i 's/^port *= *[^ ]*/port = 5433                             #/' "${PG_OLD_TEMP_DATA_PATH}"postgresql.conf
sed -i 's#^host    all             all              0.0.0.0/0                 md5#host    all             all              0.0.0.0/0                 trust#g' "${PG_OLD_TEMP_DATA_PATH}"pg_hba.conf
sed -i 's#^host    all             all              ::/0                      md5#host    all             all              ::/0                      trust#g' "${PG_OLD_TEMP_DATA_PATH}"pg_hba.conf

sudo -u postgres "${PG_OLD_BIN_PATH}/pg_ctl" -D "${PG_OLD_TEMP_DATA_PATH}" -o "-c config_file=${PG_OLD_TEMP_DATA_PATH}postgresql.conf" -l logfile_old start

OLD_LC_COLLATE="$(sudo -u postgres psql -h localhost -p 5433 -d gvmd -AXqtc "SHOW LC_COLLATE;")"
OLD_LC_CTYPE="$(sudo -u postgres psql -h localhost -p 5433 -d gvmd -AXqtc "SHOW LC_CTYPE;")"


# FIX symlink to libgvm-pg-server for old versions with different location
# on new DB should we fix the path
ln -s /usr/lib/libgvm-pg-server.so /usr/local/lib/libgvm-pg-server.so

# NEW SERVER DATA PORT CHANGE
echo "init new db version ${PG_NEW_VERSION}"
mkdir -p "${PG_NEW_DATA_PATH}" || true
chown -R "${NEW_UID}:${NEW_GID}" "${PG_NEW_DATA_PATH}"
sudo -u postgres "${PG_NEW_BIN_PATH}/initdb" -D "${PG_NEW_DATA_PATH}" -E 'UTF-8' "--lc-collate=${OLD_LC_COLLATE}" "--lc-ctype=${OLD_LC_CTYPE}"

if [ -f "${PG_OLD_DATA_PATH}.firstrun" ] || [ -f "${PG_OLD_TEMP_DATA_PATH}.firstrun" ]; then
  touch "${PG_NEW_DATA_PATH}.firstrun"
fi
if [ -f "${PG_OLD_DATA_PATH}.upgrade_to_21.4.0" ] || [ -f "${PG_OLD_TEMP_DATA_PATH}.upgrade_to_21.4.0" ]; then
  touch "${PG_NEW_DATA_PATH}.upgrade_to_21.4.0"
fi

# Copy old config
cp "${PG_OLD_DATA_PATH}postgresql.conf" "${PG_NEW_DATA_PATH}postgresql.conf"
cp "${PG_OLD_DATA_PATH}pg_hba.conf" "${PG_NEW_DATA_PATH}pg_hba.conf"
chown "${NEW_UID}:${NEW_GID}" "${PG_NEW_DATA_PATH}postgresql.conf" "${PG_NEW_DATA_PATH}pg_hba.conf"

sudo -u postgres "${PG_NEW_BIN_PATH}/pg_ctl" -D "${PG_NEW_DATA_PATH}" -o "-c config_file=${PG_NEW_DATA_PATH}postgresql.conf" -l logfile_new start

# stop servers again
sudo -u postgres "${PG_OLD_BIN_PATH}/pg_ctl" -D "${PG_OLD_TEMP_DATA_PATH}" -o "-c config_file=${PG_OLD_TEMP_DATA_PATH}postgresql.conf" -l logfile_old stop
sudo -u postgres "${PG_NEW_BIN_PATH}/pg_ctl" -D "${PG_NEW_DATA_PATH}" -o "-c config_file=${PG_NEW_DATA_PATH}postgresql.conf" -l logfile_new stop

echo "Start checking of Postgresql pg_upgrade from ${PG_OLD_VERSION} to ${PG_NEW_VERSION}"
sudo -u postgres "${PG_NEW_BIN_PATH}/pg_upgrade" --old-bindir="${PG_OLD_BIN_PATH}/" --new-bindir="${PG_NEW_BIN_PATH}/" --old-datadir="${PG_OLD_TEMP_DATA_PATH}" --new-datadir="${PG_NEW_DATA_PATH}" --jobs 2 --check

read -p "Would you start the pg_upgrade process? Please type 'Y' to continue..." -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi

sudo -u postgres "${PG_NEW_BIN_PATH}/pg_upgrade" --old-bindir="${PG_OLD_BIN_PATH}/" --new-bindir="${PG_NEW_BIN_PATH}/" --old-datadir="${PG_OLD_TEMP_DATA_PATH}" --new-datadir="${PG_NEW_DATA_PATH}" --jobs 2

sudo -u postgres "${PG_OLD_BIN_PATH}/pg_ctl" -D "${PG_OLD_TEMP_DATA_PATH}" -o "-c config_file=${PG_OLD_TEMP_DATA_PATH}postgresql.conf" -l logfile_old start
sudo -u postgres "${PG_NEW_BIN_PATH}/pg_ctl" -D "${PG_NEW_DATA_PATH}" -o "-c config_file=${PG_NEW_DATA_PATH}postgresql.conf" -l logfile_new start

sudo -u postgres ./analyze_new_cluster.sh

if [[ "$DELETE_OLD" == "TRUE" ]]; then
  sudo -u postgres ./delete_old_cluster.sh
fi

# Update old socket path to new socket path for OpenVAS
sudo -u postgres psql -d gvmd -c "UPDATE public.scanners SET host='/run/ospd/ospd-openvas.sock' WHERE name='OpenVAS Default' and (host='/var/run/ospd/ospd.sock' or host='/run/ospd/ospd.sock');"

# FIX Path to libgvm-pg-server
sudo -u postgres psql -d gvmd <<SQL
CREATE OR REPLACE FUNCTION public.hosts_contains(
	text,
	text)
    RETURNS boolean
    LANGUAGE 'c'
    COST 1
    IMMUTABLE PARALLEL UNSAFE
AS '/usr/lib/libgvm-pg-server', 'sql_hosts_contains'
;

ALTER FUNCTION public.hosts_contains(text, text)
    OWNER TO dba;
CREATE OR REPLACE FUNCTION public.max_hosts(
	text,
	text)
    RETURNS integer
    LANGUAGE 'c'
    COST 1
    VOLATILE PARALLEL UNSAFE
AS '/usr/lib/libgvm-pg-server', 'sql_max_hosts'
;

ALTER FUNCTION public.max_hosts(text, text)
    OWNER TO dba;
CREATE OR REPLACE FUNCTION public.next_time_ical(
	text,
	text)
    RETURNS integer
    LANGUAGE 'c'
    COST 1
    VOLATILE PARALLEL UNSAFE
AS '/usr/lib/libgvm-pg-server', 'sql_next_time_ical'
;

ALTER FUNCTION public.next_time_ical(text, text)
    OWNER TO dba;
CREATE OR REPLACE FUNCTION public.next_time_ical(
	text,
	text,
	integer)
    RETURNS integer
    LANGUAGE 'c'
    COST 1
    VOLATILE PARALLEL UNSAFE
AS '/usr/lib/libgvm-pg-server', 'sql_next_time_ical'
;

ALTER FUNCTION public.next_time_ical(text, text, integer)
    OWNER TO dba;

CREATE OR REPLACE FUNCTION public.regexp(
	text,
	text)
    RETURNS boolean
    LANGUAGE 'c'
    COST 1
    VOLATILE PARALLEL UNSAFE
AS '/usr/lib/libgvm-pg-server', 'sql_regexp'
;

ALTER FUNCTION public.regexp(text, text)
    OWNER TO dba;
SQL
sudo -u postgres "${PG_NEW_BIN_PATH}/pg_ctl" -D "${PG_NEW_DATA_PATH}" -o "-c config_file=${PG_NEW_DATA_PATH}postgresql.conf" -l logfile_new stop
sudo -u postgres "${PG_OLD_BIN_PATH}/pg_ctl" -D "${PG_OLD_TEMP_DATA_PATH}" -o "-c config_file=${PG_OLD_TEMP_DATA_PATH}postgresql.conf" -l logfile_old stop

chown -R "${OLD_UID}:${OLD_GID}" "${PG_NEW_DATA_PATH}"
apt-get remove -y --purge "postgresql-${PG_OLD_VERSION}" "postgresql-client-${PG_OLD_VERSION}" "postgresql-server-dev-${PG_OLD_VERSION}"
apt-get autoremove -y
rm -rf ${PG_OLD_TEMP_DATA_PATH}
