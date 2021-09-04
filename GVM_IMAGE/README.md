### Deploying Distributed Greenbone GVM GSA with openvas

Depending on your hardware, it can take anywhere from a few seconds to 10+ minutes while the NVTs are scanned and the database is rebuilt. The default admin user account is created after this process has completed. If you are unable to access the web interface, it means it is still loading (be patient).


This command will pull the image, create the container, and start it:

Before and equal Image TAG `21.4.0-v5` 
```console
docker run --detach --publish 8080:9392 --publish 5432:5432 --publish 2222:22 --env DB_PASSWORD="postgres DB password" --env PASSWORD="webUI password" --volume gvm-data:/data --name gvm securecompliance/gvm
```

With Image TAG after `21.4.0-v5`
```console
docker run --detach --publish 8080:9392 --publish 5432:5432 --publish 2222:22 --env DB_PASSWORD="postgres DB password" --env PASSWORD="webUI password" --volume ./storage/postgres-db:/opt/database --volume ./storage/openvas-plugins:/var/lib/openvas/plugins --volume ./storage/gvm:/var/lib/gvm --volume ./storage/ssh:/etc/ssh --name gvm securecompliance/gvm
```
If you need to update the container, run `docker pull securecompliance/gvm` to get the latest version before running the above command.

##### Environment variables

Environment variables that can be specified with the --env parameter are documented in [Environment Variables](VARIABLES/README.md).

Those settings include the username and password for the web interface, setting the timezone, etc.



### NVD Download Status
> NOTE:When you run the docker container for the first time, you may not be able to connect right away. This is because the docker container is downloading nvd information for it.
>
> !!! It can take based on you bandwidth up to 10 minutes or longer.

To check the status of the NVD download for the docker container please run this command

```bash
docker logs -f --tail=20 <container-name>

# or
docker exec -ti <nameOrIDofContainer> cat /var/log/gvm/(gvmd|openvas|gsad).log 

# or
docker exec -ti <nameOrIDofContainer> supervisorctl tail <service>
```

**RESULT**
```
### THIS IS AN EXAMPLE ###
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

