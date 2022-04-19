# syntax=docker/dockerfile:1.4
#FROM debian:11-slim AS latest
FROM deineagenturug/gvm:latest AS latest

CMD ["/opt/setup/scripts/db_upgrade.sh"]

COPY scripts /opt/setup/scripts/
RUN chmod -R +x /opt/setup/scripts/*.sh

WORKDIR /work
