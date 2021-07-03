### Environment variables

These settings can be set in the docker command line with the --env parameter, or edited in the docker-compose file.

| Name        | Description                                                  | Default Value |
| --------    | ------------------------------------------------------------ | ------------- |
| USERNAME    | Default admin username                                       | admin         |
| PASSWORD    | Default admin password                                       | admin         |
| PASSWORD_FILE    | Default no password file for Docker Swarm Secrets - if set PASSWORD is ignored |          |
| DB_PASSWORD | This sets the postgres DB password                           | random        |
| DB_PASSWORD_FILE | Default no password file for Docker Swarm Secrets - if set DB_PASSWORD is ignored |         |
| SSHD        | This needs to be set to true if you are using the remote scanner    | false         |
| TZ          | Timezone name for a list look here: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones | UTC           |
| RELAYHOST   | The IP address or hostname to send emails through.           | 127.17.0.1|
| SMTPPORT    | The TCP port for the RELAYHOST                               | 25 |
| AUTO_SYNC   | Synchronize definitions automatically on start up            | true |
| HTTPS       | Use HTTPS for the web interface. Use HTTP if false           | true |
