FROM postgres:12-bullseye

COPY --from=securecompliance/gvmd:latest /gvm/lib /gvm/lib/

COPY gvm-init.sh /docker-entrypoint-initdb.d/gvm-init.sh

RUN apt-get update && \
    apt-get install --no-install-recommends --assume-yes libglib2.0-0 libical3 libgpgme11 libradcli4 libssh-gcrypt-4 libhiredis0.14 && \
    apt-get clean

ENV LD_LIBRARY_PATH=/gvm/lib/
