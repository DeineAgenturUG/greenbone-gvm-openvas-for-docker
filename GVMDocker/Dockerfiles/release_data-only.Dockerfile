FROM deineagenturug/gvm:latest AS data-only

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    SETUP=1 \
    OPT_PDF=0

RUN ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime &&  \
    echo "$TZ" >/etc/timezone && \
    /opt/setup/scripts/entrypoint.sh /usr/bin/supervisord -c /etc/supervisord.conf

RUN tar -czf /data.tar.gz /opt/database /var/lib/openvas/plugins /var/lib/gvm

ENV SETUP=0



FROM scratch
COPY --from=data-only /data.tar.gz /data.tar.gz
