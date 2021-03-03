## FAQ


### Question 1 - How To Change Default Admin Password


```shell
su -c "gvmd --user=admin --new-password=new_password" gvm
```



### Question 2 - python-gvm for automation with the docker image but while establishing connection it fails saying "could not find /usr/local/var/run/gvmd.sock"




```shell
# Replace
su -c "gvmd --listen=0.0.0.0 --port=9390" 

# gvm in the start.sh with

su -c "gvmd --unix-socket=/data/gvmd/gvmd.sock" gvm. 

# This will create a socket in the /data/gvmd folder
```

### Question 3 - Can't view scan reports - get "An error has occurred on this page" 

> When mounting your volumes, use this specific syntax instead: `--volume gvm-data:/data:exec`, this allows the report-building scripts to be executed from the volume.


### Question 4 - GMP Refusing Connections

#### Solution 1

enable SSH, and have docker map it to port `9222`

add a public key to `/data/scanner-ssh-keys/authorized_keys`

Then use ssh port forwarding to access the API port with `ssh -N -L 9390:localhost:9390 gvm@localhost -p 9222 -i <private key file>`

This can be configured to access the container's API port from any machine that can connect to the exposed `9222` ssh port by changing the ssh host. Once you run this, you then have a `localhost:9390` port mapped into the container tunnelled securely over ssh. You can then tell `python-gvm` or `gvm-cli` to connect with TLS to that port.


#### Question 5 - TypeError: Cannot read property 'userTags' of undefined

There is a permission problem on the following directory:

`INSTALL_DIR/var/lib/gvm/gvmd/report_formats`

The missing <report> elements within the outer `<report id="...">` are created by the report formatting scripts. These scripts could not run because the above directory has no read or execute permissions for anyone but the directory owner. The scripts are run as "`nobody`" in "`nogroup`".

Solution:

Run the following command:

`chmod 755 INSTALL_DIR/var/lib/gvm/gvmd/report_formats`

- https://community.greenbone.net/t/fix-for-reports-not-displaying-in-gvm-20-8-due-to-javascript-errors/7905
- https://github.com/greenbone/gsa/issues/2389









