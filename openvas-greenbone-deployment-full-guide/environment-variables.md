- RELAYHOST : The IP address or hostname of the email relay to send emails through. Default = 172.17.01 
<!--(This is default for the docker host. If you are running the mail relay on your docker host, this should work, but you will need to make sure you allow the conections through the host`s firewall/iptables)-->
```
-e RELAYHOST=mail.example.com 
```

- SMTPPORT : The TCP port for the RELAYHOST. Default = 25
```
-e RELAYHOST=25
```
