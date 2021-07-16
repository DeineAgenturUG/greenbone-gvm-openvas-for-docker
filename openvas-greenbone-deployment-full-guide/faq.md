## FAQ


### Question 1 - How To Change Default Admin Password


```shell
# this can be run direct in the container
su -c "gvmd --user=admin --new-password=new_password" gvm

# or
# run this from host
docker exec -ti <docker-container-id-or-name> /reset-gvmd-admin-password.sh
```

---------

### Question 2 - python-gvm for automation with the docker image but while establishing connection it fails saying "could not find /usr/local/var/run/gvmd.sock"



```shell
# Replace
su -c "gvmd --listen=0.0.0.0 --port=9390" 

# gvm in the start.sh with

su -c "gvmd --unix-socket=/usr/var/run/gvmd.sock/gvmd.sock" gvm. 

# This will create a socket in the /usr/var/run/ folder
```


---------

### Question 3 - Can't view scan reports - get "An error has occurred on this page" 

> When mounting your volumes, use this specific syntax instead: `--volume gvm-data:/data:exec`, this allows the report-building scripts to be executed from the volume.


---------

### Question 4 - GMP Refusing Connections

#### Solution 1

enable SSH, and have docker map it to port `9222`

add a public key to `var/lib/gvm/.ssh/authorized_keys`

Then use ssh port forwarding to access the API port with `ssh -N -L 9390:localhost:9390 gvm@localhost -p 9222 -i <private key file>`

This can be configured to access the container's API port from any machine that can connect to the exposed `9222` ssh port by changing the ssh host. Once you run this, you then have a `localhost:9390` port mapped into the container tunnelled securely over ssh. You can then tell `python-gvm` or `gvm-cli` to connect with TLS to that port.


---------

### Question 5 - TypeError: Cannot read property 'userTags' of undefined

There is a permission problem on the following directory:

`INSTALL_DIR/var/lib/gvm/gvmd/report_formats`

The missing <report> elements within the outer `<report id="...">` are created by the report formatting scripts. These scripts could not run because the above directory has no read or execute permissions for anyone but the directory owner. The scripts are run as "`nobody`" in "`nogroup`".

Solution:

Run the following command:

`chmod 755 INSTALL_DIR/var/lib/gvm/gvmd/report_formats`

- https://community.greenbone.net/t/fix-for-reports-not-displaying-in-gvm-20-8-due-to-javascript-errors/7905
- https://github.com/greenbone/gsa/issues/2389


---------
### Question 6 - Problem when generate pdf report larger than 1Mo and send it by email

#### Solution:

If you run into this issue, this can be temporary solved by adding the following to the `script.sh`

```
su -c "gvmd --listen=0.0.0.0 --port=9390 --max-email-attachment-size="-1" --max-email-include-size="-1" --max-email-message-size="-1"" gvm
```
> NOTE: If we get more issues related to this we will research long-term solution. 

---------


### Question 7 - Is there a way of having Super Admins?

#### Solution

You will need to find the name of the docker container first

```
docker ps
```

Then run the following

```
docker exec -it <name> bash
su - gvm
gvmd --create-user=MySecondSuperAdmin -v --role="Super Admin"
```
  
This will result in a message saying that the user has been created along with the new password - take note of this before proceeding.

If you have already create a normal admin and would like to become a super admin, do the following


```
docker exec -it <name> bash
su - gvm
gvmd --create-user=MyUser2 -v --role="Super Admin"
gvmd –-delete-user=MyUser --inheritor=MyUser2
gvmd --create-user=MyUser -v --role="Super Admin"
gvmd –-delete-user=MyUser2 --inheritor=MyUser
```
  
  
Ensuring you take note of the password for the 2nd create user


### Question 8 - How can I use my own SSL Certificate?

#### Solution 1

You can build your own image:
```
FROM securecompliance/gvm:latest
ENV HTTPS=true \
    CERTIFICATE=/etc/ssl/cert/MY_SSL_CERT.pem \
    CERTIFICATE_KEY=/etc/ssl/private/MY_SSL_CERT.key
COPY ./ssl/MY_SSL_CERT.pem /etc/ssl/cert/MY_SSL_CERT.pem
COPY ./ssl/MY_SSL_CERT.key /etc/ssl/private/MY_SSL_CERT.key
RUN chmod 0644 /etc/ssl/cert/MY_SSL_CERT.pem ; chmod 0600 /etc/ssl/private/MY_SSL_CERT.key
```


#### Solution 2

You can use Volumes:

`-v ./ssl/:/secrets/ssl/ -e HTTPS=true -e CERTIFICATE=/secrets/ssl/MY_SSL_CERT.pem -e CERTIFICATE=/secrets/ssl/MY_SSL_CERT.key`




