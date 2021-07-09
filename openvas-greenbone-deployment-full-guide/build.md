### Build the Image

This settings can be used while you build your own image via `docker build`.

`--build-arg SETUP=1` - This setting will build the image with an initialized data structure. Usefull if you don't use on the later state the volumes, let say like a standalone version. Or when you only use some of the volumes bind to docker volumes or system volumes. Like you only would like to use only the volume form the database (`/opt/database`) or the ssh for your custom settings (`/etc/ssh`)

`--build-arg OPT_PDF=1` - This setting will add texlive for PDF generation. This option is to reduce the size of the image. By default the dependencies of texlive are not installed.

> Also you can use each of the   [Environment Variables](openvas-greenbone-deployment-full-guide/environment-variables.md) as `--build-arg` like the TZ Variable `--build-arg TZ=Europe/Berlin` so this will be the default one in the image and you don't need to set this on your `docker-compose.yml` or as Environment on `docker run`