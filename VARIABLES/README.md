### Environment variables

#### Other options that can be changed in the docker run command:

```
# until TAG <= 21.4.0-v5
--volume gvm-data:/data

# or TAG > 21.4.0-v5
--volume ./storage/postgres-db:/opt/database 
--volume ./storage/openvas-plugins:/var/lib/openvas/plugins
--volume ./storage/gvm:/var/lib/gvm 
--volume ./storage/ssh:/etc/ssh
``` 

| Environment variables     	| Description                                                                                                                                                                                                                                                     	|
|---------------------------	|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	|
| `--volume gvm-data:/data` 	| This is for creating a persistent volume so you don't lose your data when you update the container. You can modify the host side (gvm-data) but it needs to mount to /data in the container.                                                                    	|
| `--name gvm`              	| Obviously you can name it whatever you\'d like. The rest of the documentation will assume that you\'ve named it gvm like we did in our example.                                                                                                                 	|
| `--publish 8080:9392`     	| This is the port designation for the WebUI.                                                                                                                                                                                                                     	|
| `--publish 8081:8081`     	| This is the port designation for the Supervisor WebUI -> Don't make it public to the internet!                                                                                                                                                                  	|
| `--publish 2222:22`       	| This is required if you would like to run the distrubted scanner setup. This allows the remote scanner to connect back to the host over SSH. For security reasons, shell access is not allowed. This is only for the remote sensor to communicate with the GVM. 	|
| `--publish 5432:5432`     	| This opens up access for database management tools to connect to the postgresql database and do advanced reporting, create graphs, etc.                                                                                                                         	|                                                                                                                                                                                                                                                     
You can use any ports you\'d like on the host side (left side) but the container side must use the ports specified.



These settings can be set in the docker command line with the --env parameter, or edited in the docker-compose file.

| Name        | Description                                                  | Default Value |
| --------    | ------------------------------------------------------------ | ------------- |
| `USERNAME`    | Default admin username                                       | admin         |
| `PASSWORD `   | Default admin password                                       | admin         |
| `PASSWORD_FILE`    | Default no password file for Docker Swarm Secrets - if set PASSWORD is ignored |          |
| `DB_PASSWORD` | This sets the postgres DB password                           | random        |
| `DB_PASSWORD_FILE` | Default no password file for Docker Swarm Secrets - if set DB_PASSWORD is ignored |         |
| `SSHD`        | This needs to be set to true if you are using the remote scanner    | false         |
| `TZ`          | Timezone name for a list look here: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones | UTC           |
| `RELAYHOST`   | The IP address or hostname to send emails through.           | 127.17.0.1|
| `SMTPPORT`    | The TCP port for the RELAYHOST                               | 25 |
| `AUTO_SYNC`   | Synchronize definitions automatically on start up            | true |
| `HTTPS`       | Use HTTPS for the web interface. Use HTTP if false           | true |
| `CERTIFICATE` | Use the Path to your SSL-Certificate | none |
| `CERTIFICATE_KEY` | Use the Path to your SSL-Certificate Private Key | none |
| `OPT_PDF`     | Install deps for PDF Reports (texlive) on firststart         | 0 |
