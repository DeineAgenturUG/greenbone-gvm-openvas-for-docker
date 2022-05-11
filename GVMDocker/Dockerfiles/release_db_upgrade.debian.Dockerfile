# syntax=docker/dockerfile:1.4
FROM debian:11-slim AS latest

CMD ["/opt/setup/scripts/db_upgrade.sh"]

COPY scripts /opt/setup/scripts/

RUN set -eu; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		apt-transport-https; \
	cp /opt/context-full/helper/config/apt-sources.org.list /etc/apt/sources.list

RUN echo "/usr/local/lib" >/etc/ld.so.conf.d/openvas.conf \
    && echo 'export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"'>>/etc/environment \
    && sed -i '7c\ \ PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"' /etc/profile \
    && ldconfig \
    && chmod -R +x /opt/setup/scripts/*.sh \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        apt-utils \
        coreutils \
        ca-certificates \
        gnupg \
        sudo \
        rsync \
        wget \
        lsb-release \
        curl \
    && echo "APT::Install-Recommends \"0\" ; APT::Install-Suggests \"0\" ;" | tee /etc/apt/apt.conf.d/10no-recommend-installs \
    && curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        dpkg zip nano xz-utils locales \
        "postgresql-common" "libpq-dev"\
        "postgresql-14" "postgresql-client-14" "postgresql-server-dev-14" "postgresql-contrib-14"  \
        "postgresql-13" "postgresql-client-13" "postgresql-server-dev-13" "postgresql-contrib-13"  \
        "postgresql-12" "postgresql-client-12" "postgresql-server-dev-12" "postgresql-contrib-12"  \
        "postgresql-11" "postgresql-client-11" "postgresql-server-dev-11" "postgresql-contrib-11"  \
        "postgresql-10" "postgresql-client-10" "postgresql-server-dev-10" "postgresql-contrib-10"  \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen \
    && useradd -r -M -d /var/lib/gvm -U -G sudo -s /bin/bash gvm \
    && usermod -aG tty gvm  \
    && usermod -aG sudo gvm \
    && echo "gvm ALL = NOPASSWD: /usr/sbin/openvas" > /etc/sudoers.d/gvm \
    && chmod 0440 /etc/sudoers.d/gvm \
    && echo "Etc/UTC" >/etc/timezone \
    && rm -rfv /tmp/* /var/cache/apk/* /var/lib/apt/lists/*
