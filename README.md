# Greenbone GVM & OpenVAS for Docker

We provide the best solution for the Greenbone Vulnerability Management.

In our Repo we (I) collect all GVM Stuff under one roof, so we can handel all the needs in a single repository.

You can find our Docker builds on docker: https://hub.docker.com/u/deineagenturug

Currently we provide this Images:

#### GVMD, OpenVAS Scanner, WebUI GSA/D
```text
docker pull deineagenturug/gvm:latest           # no pre initialisation, no PDF Report support - normal used with volumes
docker pull deineagenturug/gvm:latest-full      # no pre initialisation, with PDF Report support - normal used with volumes
docker pull deineagenturug/gvm:latest-data      # pre initialisation, no PDF Report support - normal NOT used with volumes
docker pull deineagenturug/gvm:latest-data-full # pre initialisation, with PDF Report support - normal NOT used with volumes
```


#### OpenVAS Scanner only as sensor for i.e. DMZ usage 
```text
docker pull deineagenturug/openvas-scanner:latest
```

I know we have right now, not documented all the things that have changed, and will change in the next month, but I think we can already start with a solid base. 

If you like to support our work you can do it via https://github.josef-froehle.de. Thank You!
