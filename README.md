---
description: Documentation for Secure Compliance Solutions projects.
---

# Overview

Secure Compliance Solutions


This docker image is based on Greenbone Vulnerability Management 21.4.0. This Docker image was developed to help steamline, cleanup, and improve reliability of the components of the Greenbone Vulnerability stack (Which includes OpenVAS).

This guide will explain how to deploy our greenbone/openvas container with the postgresql database accessible for third party database tools. This also assumes that you will use the remote openvas scanner for a distributed deploymenti (not required). This allows you control multiple lightweight openvas scanners over SSH with a single webUI. We have modified the way the remote scanner communicates to improve the security and ease of setup.
