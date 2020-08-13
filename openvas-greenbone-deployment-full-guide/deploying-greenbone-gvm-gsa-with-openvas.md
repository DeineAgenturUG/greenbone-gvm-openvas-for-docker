### Deploying Distributed Greenbone GVM GSA with openvas

This command will pull, create, and start the container:
```console
docker run --detach --publish 8080:9392 --publish 5432:5432 --publish 2222:22 --env PASSWORD="Your admin password here" --volume gvm-data:/data --name gvm securecompliance/gvm
```
If you need to update the container, please run `docker pull securecompliance/gvm` to get the latest version before running the above command.
##### The following are variables that can be set/modified using the `--env` option

| Name     | Description                                                  | Default Value |
| -------- | ------------------------------------------------------------ | ------------- |
| USERNAME | Default admin username                                       | admin         |
| PASSWORD | Default admin password                                       | admin         |
| HTTPS    | If you do not want to use HTTPS this can be set to false                     | true          |
| SSHD     | This needs to be set to true if you are using the remote scanner    | false         |
| TZ       | Timezone name for a list look here: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones | UTC           |

##### Other options that can be changed in the docker run command:

`--env PASSWORD="Your admin password here"` - This is for setting the webUI admin password. If you remove this from the command, the default username:password will be admin:admin. You need to change the password inside the quotes.
(e.g. `--env PASSWORD="SuperSecurePassword"`)

`--env DB_PASSWORD="Use a different password here"` - This sets the postrgesql database password. This is needed if you are going to use the metabase connection or any other database management tool to run reports that greenbone doesn\'t give you. 
(e.g. `--env DB_PASSWORD=UltraSecurePassword1"`)

`--volume gvm-data:/data` - This is for creating a persistent volume so you dont lose your data when you update the container. You can modify the host side (gvm-data) but it needs to mount to /data in the container.

`--name gvm` Obviously you can name it whatever you\'d like. The rest of the documentation will assume that you\'ve named it gvm like we did in our example.

`--publish 8080:9392` - This is the port designation for the WebUI.

`--publish 2222:22` - This is required if you would like to run the distrubted scanner setup. This allows the remote scanner to connect back to the host over SSH. For security reasons, shell access is not allowed. This is **only** for the remote sensor to communicate with the GVM.

`--publish 5432:5432` - This opens up access for database management tools to connect to the postgresql database and do advanced reporting, create graphs, etc. 

You can use any ports you\'d like on the host side (left side) but the container side must use the ports specified.
