FROM alpine:3.14

RUN apk add --no-cache openssh-server

RUN adduser --disabled-password gvm

COPY sshd_config /etc/ssh/sshd_config

COPY start.sh /start.sh

CMD ["/start.sh"]
