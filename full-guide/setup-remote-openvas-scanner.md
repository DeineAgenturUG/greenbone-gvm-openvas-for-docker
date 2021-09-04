### Setup remote OpenVAS scanner for a distributed openvas setup


A typical GVM deployment with remote scanners requires the GVM (server) to connect to the scanner. We found this to be problematic when scanning clients who either can\'t, or don\'t want to, setup port forwarding. We modify this in our setup by making the remote scanner connect to the GVM server using ssh keys. 

After starting the remote scanner, you will find the scanner\'s Public Key and the \"Scanner ID\" in the docker logs. This information is used to add the scanner to the GVM server using a script we\'ve created.

##### The following are variables that can be set/modified using the `--env` option

| Name           | Description                            | Default Value      |
| -------------- | -------------------------------------- | ------------------ |
| MASTER_ADDRESS | IP or Hostname of the GVM container    | (No default value) |
| MASTER_PORT    | SSH server port from the GVM container | 22                 |

Steps to deploy remote scanner:

1. Make sure you deployed the GVM server container with the ssh port published. (reference link)

2. Deploy the scanner container on the remote host

Before and equal Image TAG `21.4.0-v5`
   ```shell
   docker run --detach --volume scanner:/data --env MASTER_ADDRESS={IP or Hostname of GVM container} --env MASTER_PORT=2222 --name scanner securecompliance/openvas
   ```

With Image TAG after `21.4.0-v5`
   ```shell
   docker run --detach --volume ./storage/openvas-plugins:/var/lib/openvas/plugins --env MASTER_ADDRESS={IP or Hostname of GVM container} --env MASTER_PORT=2222 --name scanner securecompliance/openvas
   ```

   Note: Refer to your GVM deployment to determine your MASTER_ADDRESS and MASTER_PORT values.

3. Watch the scanner logs for the \"Scanner id\" and Public key

   Note: this assumes you\'ve named your container \"scanner\"
   ```
   docker logs -f scanner
   ```
   Example output:
   ```
   -------------------------------------------------------
   Scanner id: df5tt4csny
   Public key: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPbE8p5zxOoPFPDiE9BCxcRd1jCVaRfOO92BO5hIfdqi df5cy5csnp
   Master host key (Check that it matches the public key from the master): [192.168.1.150]:2222 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5A55AIMHHl4neiOBuBfCPQtJp/WQuyb6xVIrgmVp3U/A7qmev
   -------------------------------------------------------
   ```

4. On the host with the GVM server container, run the following command:

   ```
   docker exec -it gvm /add-scanner.sh
   ```
   This will prompt you for your scanner name, \"Scanner id\", and Public Key

   Scanner Name: **This can be anything you want**
   Scanner ID: **generated id from remote openvas scanner**
   Scanner public key: **private key from scanner**

   You will receive a confirmation that the scanner has been added

5. Login to the GVM server web interface and navtigate to **Configuration -> Scanners** to see the scanner you just added.
6. You can click the sheild icon next to the scanner to verify the scanner connectivity.
