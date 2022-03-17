
FROM deineagenturug/gvm:latest-data AS latest-data-full

ARG SETUP=1
ARG OPT_PDF=1

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    SETUP=${SETUP} \
    OPT_PDF=${OPT_PDF}

RUN sudo apt-get update && \
    sudo apt-get install -y --no-install-recommends \
        texlive-fonts-recommended \
        texlive-latex-extra ; \
    unset OPT_PDF

ENV SETUP=0

RUN set -eu; \
    rm -rfv /var/lib/gvm/CA || true \
    && rm -rfv /var/lib/gvm/private || true \
    && rm /etc/localtime || true\
    && echo "Etc/UTC" >/etc/timezone \
    && rm -rfv /tmp/* /var/cache/apk/* /var/lib/apt/lists/* \
    && echo "!!! FINISH Setup !!!"

VOLUME [ "/opt/database", "/var/lib/openvas/plugins", "/var/lib/gvm", "/etc/ssh" ]
