FROM alpine:3

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]

ARG SUPVISD=supervisorctl
ARG DEBUG=N
ARG TZ=UTC
ARG SETUP=0

RUN mkdir -p /repo/main \
    && mkdir -p /repo/community

COPY apk-build/target/ /repo/
COPY apk-build/user.abuild/*.pub /etc/apk/keys/

ENV SUPVISD=${SUPVISD:-supervisorctl} \
    DEBUG=${DEBUG:-N} \
    TZ=${TZ:-UTC} \
    SETUP=${SETUP:-0}

RUN { \
    echo '@custcom /repo/community/'; \
    echo 'https://dl-5.alpinelinux.org/alpine/v3.14/main/' ; \
    echo 'https://dl-5.alpinelinux.org/alpine/v3.14/community/' ;\
    echo 'https://dl-4.alpinelinux.org/alpine/v3.14/main/' ; \
    echo 'https://dl-4.alpinelinux.org/alpine/v3.14/community/' ;\
    echo 'https://dl-cdn.alpinelinux.org/alpine/v3.14/main/' ; \
    echo 'https://dl-cdn.alpinelinux.org/alpine/v3.14/community/' ; \
    } >/etc/apk/repositories \
    && cat /etc/apk/repositories \
    && sleep 5 \
    && apk update --update-cache \
    && sleep 5 \
    && apk upgrade --available \
    && sleep 5 \
    && apk add --allow-untrusted curl su-exec tzdata bash openssh supervisor openvas@custcom openvas-smb@custcom openvas-config@custcom gvm-libs@custcom ospd-openvas@custcom \
    && mkdir -p /var/log/supervisor/ \
    && sync

COPY gvm-sync-data/gvm-sync-data.tar.xz /opt/gvm-sync-data.tar.xz
COPY scripts/* /
COPY config/supervisord.conf /etc/supervisord.conf
COPY config/redis-openvas.conf /etc/redis.conf

VOLUME [ "/var/lib/openvas/plugins" ]

RUN if [ "${SETUP}" == "1" ]; then \
    ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime && echo "$TZ" >/etc/timezone \
    && /usr/bin/supervisord -c /etc/supervisord.conf || true ; \
    unset SETUP ;\
    fi \
    && rm /etc/localtime || true\
    && echo "UTC" >/etc/timezone \
    && rm -rf /tmp/* /var/cache/apk/* \
    && echo "!!! FINISH Setup !!!"

#
#   Owned by User gvm
#
#       /run/ospd
#       /var/lib/openvas/plugins
#       /var/lib/gvm
#       /var/lib/gvm/gvmd
#       /var/lib/gvm/gvmd/gnupg
#       /var/log/gvm
#
#   Owned by Group gvm
#
#       /run/ospd
#       /var/lib/gvm
#       /var/lib/gvm/gvmd
#       /var/lib/gvm/gvmd/gnupg
#