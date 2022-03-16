FROM bitnami/minideb:bullseye

RUN apt-get update && \
    apt-get install --no-install-recommends --assume-yes ca-certificates curl tar xz-utils rsync && \
    apt-get clean

COPY start.sh /start.sh

CMD ["/start.sh"]
