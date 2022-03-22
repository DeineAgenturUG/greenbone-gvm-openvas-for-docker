# syntax=docker/dockerfile:1.4
FROM docker.elastic.co/logstash/logstash:7.9.1
RUN rm -f /usr/share/logstash/pipeline/logstash.conf
ADD https://jdbc.postgresql.org/download/postgresql-42.2.16.jar /usr/share/logstash/postgresql.jar
ADD config/ /usr/share/logstash/config/
ADD pipeline/ /usr/share/logstash/pipeline/
ADD get-results.sql /usr/share/logstash/
USER root
RUN chown logstash:root -R /usr/share/logstash
USER logstash
