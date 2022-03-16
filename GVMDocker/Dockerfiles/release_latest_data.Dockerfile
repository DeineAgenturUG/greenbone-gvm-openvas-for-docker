
FROM latest AS latest-data
ARG SETUP=1
ARG OPT_PDF=0

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    SETUP=${SETUP} \
    OPT_PDF=${OPT_PDF}

RUN ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime &&  \
    echo "$TZ" >/etc/timezone && \
    /opt/setup/scripts/entrypoint.sh /usr/bin/supervisord -c /etc/supervisord.conf

ENV SETUP=0

RUN set -eu; \
    rm -rfv /var/lib/gvm/CA || true \
    && rm -rfv /var/lib/gvm/private || true \
    && rm /etc/localtime || true\
    && echo "Etc/UTC" >/etc/timezone \
    && rm -rfv /tmp/* /var/cache/apk/* /var/lib/apt/lists/* \
    && echo "!!! FINISH Setup !!!"

VOLUME [ "/opt/database", "/var/lib/openvas/plugins", "/var/lib/gvm", "/etc/ssh" ]
