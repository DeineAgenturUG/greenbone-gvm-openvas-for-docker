FROM redis:6-alpine
COPY redis.conf /usr/local/etc/redis/redis.conf
RUN mkdir /run/redis && chown redis:redis -R /run/redis
CMD [ "redis-server", "/usr/local/etc/redis/redis.conf" ]
