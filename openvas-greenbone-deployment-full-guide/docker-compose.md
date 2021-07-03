### Deploy with Docker Compose

A docker-compose.yml file is included for easier deployment via [docker-compose](https://docs.docker.com/compose/install/) or [Portainer](https://www.portainer.io/).  This allows you to keep all the required settings in one place, instead of depending on remembering the docker run command parameters to use.

#### Changes to make before deploying

You must edit the docker-compose.yml file to suit your environment.

##### Persistent data

At a minimum, you must replace `<path to data>` with the path on the host system or a docker volume to store persistent data in. The path can be absolute or relative to the directory you are launching the container from eg:

Before and equal TAG `21.4.0-v5` 
```yaml
volumes:
    - ./gvmdata:/data
```
or
```yaml
volumes:
    - /opt/gvmdata:/data
```

With TAG after `21.4.0-v5`
```yaml
volumes:
    - ./storage/postgres-db:/opt/database
    - ./storage/openvas-plugins:/var/lib/openvas/plugins
    - ./storage/gvm:/var/lib/gvm
    - ./storage/ssh:/etc/ssh 
```
##### Environment variables

You can change the environment variables listed. They are already set to their default values. Each setting is documented in [Environment Variables](environment-variables.md). Note that `DB_PASSWORD='none'` does not set a password at all (doesn't set it to 'none').

##### Additional ports
By default only the web interface is exposed on port 8080. You can change 8080 to a different port if 8080 is already in use on your docker host.  Two additional ports are disabled by default and can be turned on if needed. Just remove the `#` at the start of the line.

If using remote sensors, uncomment the line `- "2222:22" # SSH for remote sensors"` to allow access to SSH.

If using external tools to access the database, uncomment the `-"5432:5432" # Access PostgreSQL database from external tools"` line.

#### Deploying using docker-compose

Run `docker-compose up -d` in the directory with the docker-compose.yml file.

#### Updating to latest image

When new containers are released, you can upgrade by running:

````bash
docker-compose pull
docker-compose up -d
````
