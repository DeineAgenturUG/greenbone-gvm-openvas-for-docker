# Greenbone Vulnerability Stack Docker Image

[![Docker Pulls](https://camo.githubusercontent.com/3e63cf99dc710db046e20197cd8a327e5db79805/68747470733a2f2f696d672e736869656c64732e696f2f646f636b65722f70756c6c732f736563757265636f6d706c69616e63652f67766d2e737667)](https://hub.docker.com/r/securecompliance/gvm/) [![Docker Stars](https://camo.githubusercontent.com/4e1e7c9b4e7a6d79c1cb606cd33473a101a0962e/68747470733a2f2f696d672e736869656c64732e696f2f646f636b65722f73746172732f736563757265636f6d706c69616e63652f67766d2e737667)](https://hub.docker.com/r/securecompliance/gvm/)

This docker image is based on Greenbone Vulnerability Management 21.4.0. This Docker image was developed to help steamline, cleanup, and improve reliability of the components of the Greenbone Vulnerability stack \(Which includes OpenVAS\).

This guide will explain how to deploy our greenbone/openvas container with the postgresql database accessible for third party database tools. This also assumes that you will use the remote openvas scanner for a distributed deploymenti \(not required\). This allows you control multiple lightweight openvas scanners over SSH with a single webUI. We have modified the way the remote scanner communicates to improve the security and ease of setup.

Depending on your hardware, it can take anywhere from a few seconds to 10+ minutes while the NVTs are scanned and the database is rebuilt. The default admin user account is created after this process has completed. If you are unable to access the web interface, it means it is still loading (be patient).
