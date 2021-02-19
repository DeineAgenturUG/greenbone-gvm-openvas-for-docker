### Deploying Distributed Greenbone GVM GSA with openvas

Read this entire page before starting your container.



This command will pull the image, create the container, and start it:
```console
docker run --detach --publish 8080:9392 --publish 5432:5432 --publish 2222:22 --env DB_PASSWORD="postgres DB password" --env PASSWORD="webUI password" --volume gvm-data:/data --name gvm securecompliance/gvm
```
If you need to update the container, run `docker pull securecompliance/gvm` to get the latest version before running the above command.
##### The following are variables that can be set/modified using the `--env` option

| Name     | Description                                                  | Default Value |
| -------- | ------------------------------------------------------------ | ------------- |
| USERNAME | Default admin username                                       | admin         |
| PASSWORD | Default admin password                                       | admin         |
| DB_PASSWORD | This sets the postgres DB password                        | random        |
| HTTPS    | If you do not want to use HTTPS this can be set to false                     | true          |
| SSHD     | This needs to be set to true if you are using the remote scanner    | false         |
| TZ       | Timezone name for a list look here: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones | UTC           |




#### Other options that can be changed in the docker run command:

`--env PASSWORD="Your admin password here"` - This is for setting the webUI admin password. If you remove this from the command, the default username:password will be admin:admin. You need to change the password inside the quotes.
(e.g. `--env PASSWORD="SuperSecurePassword"`)

`--env DB_PASSWORD="Use a different password here"` - This sets the postrgesql database password. This is needed if you are going to use the metabase connection or any other database management tool to run reports that greenbone doesn\'t give you. 
(e.g. `--env DB_PASSWORD="UltraSecurePassword1"`)

`--env USERNAME="Alternate username"` - Use this variable if you would like to use a username other than the default admin username 
(e.g. `--env USERNAME="frank"`)

`--volume gvm-data:/data` - This is for creating a persistent volume so you dont lose your data when you update the container. You can modify the host side (gvm-data) but it needs to mount to /data in the container.

`--name gvm` Obviously you can name it whatever you\'d like. The rest of the documentation will assume that you\'ve named it gvm like we did in our example.

`--publish 8080:9392` - This is the port designation for the WebUI.

`--publish 2222:22` - This is required if you would like to run the distrubted scanner setup. This allows the remote scanner to connect back to the host over SSH. For security reasons, shell access is not allowed. This is **only** for the remote sensor to communicate with the GVM.

`--publish 5432:5432` - This opens up access for database management tools to connect to the postgresql database and do advanced reporting, create graphs, etc. 

You can use any ports you\'d like on the host side (left side) but the container side must use the ports specified.


### NVD Download Status
> NOTE:When you run the docker container for the first time, you may not be able to connect right away. This is because the docker container is downloading nvd information for it.
> 
To check the status of the NVD download for the docker container please run this command

```bash
docker logs -f --tail=20 gvm-container-name
```

**RESULT**
```
COPYING
          1,719 100%    1.64MB/s    0:00:00 (xfr#1, to-chk=43/45)
nvdcve-2.0-2002.xml
     15,357,413 100%  400.96kB/s    0:00:37 (xfr#2, to-chk=42/45)
nvdcve-2.0-2003.xml
      4,332,608 100%  372.72kB/s    0:00:11 (xfr#3, to-chk=41/45)
nvdcve-2.0-2004.xml
      8,910,666 100%  386.15kB/s    0:00:22 (xfr#4, to-chk=40/45)
nvdcve-2.0-2005.xml
     14,615,135 100%  399.35kB/s    0:00:35 (xfr#5, to-chk=39/45)
nvdcve-2.0-2006.xml
     23,948,587 100%  394.35kB/s    0:00:59 (xfr#6, to-chk=38/45)
nvdcve-2.0-2007.xml
     22,987,205 100%  400.76kB/s    0:00:56 (xfr#7, to-chk=37/45)
nvdcve-2.0-2008.xml
     24,680,422 100%  394.21kB/s    0:01:01 (xfr#8, to-chk=36/45)
nvdcve-2.0-2009.xml
     21,491,217 100%  397.19kB/s    0:00:52 (xfr#9, to-chk=35/45)
nvdcve-2.0-2010.xml
```

