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







