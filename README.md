# GVM Logstash

This docker image contains logstash configured to pull data from a Greenbone Vulnerability Manager instance.



Example command:

```sh
docker run -d \
-e DB_PASSWORD=<GVM postgres database password> \
-e DB_USER=gvm \
-e DB_HOST=<IP or Hostname for the GVM postgres database> \
-e ES_HOST=<IP or Hostname for elasticsearch> \
-e ES_USER=<Username for elasticsearch> \
-e ES_PASSWORD=<Password for elasticsearch user> \
--name gvm-logstash \
docker.pkg.github.com/secure-compliance-solutions-llc/gvm-logstash/gvm-logstash:master
```



| Environment Variable Name | Default Value |
| ------------------------- | ------------- |
| DB_HOST                   | gvm           |
| DB_USER                   | gvm           |
| DB_PASSWORD               |               |
| ES_HOST                   | elasticsearch |
| ES_USER                   | gvm-logstash  |
| ES_PASSWORD               |               |