---
name: Bug report
about: Create a report to help us improve
title: "[Bug]"
labels: bug
assignees: Dexus

---

<!--
################################################################################
Before you open a bug issue, please read the documentation. If you do not find an
answer to your problem there, please look in the issues that have already been closed.
Only if you still have not found an answer to your problem should you open a new issue.
https://github.com/DeineAgenturUG/greenbone-gvm-openvas-for-docker/wiki
################################################################################
-->

<!--
################################################################################
NOTE: If You mention a file like a configuration file (`main.cf` etc) or 
another file in the issue description please include it into issue using a code block.
################################################################################
-->


**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Host Device:**
 - OS:
 - Architecture:
 - Version:

**Image in use:**
- Self build? 
- Output from `docker image inspect <image>` :
```
# docker image inspect <image> 
```

**Log Outputs:**

- Output from `docker logs <image>` :
```
# docker logs <image> 
```
- Output from `docker exec -ti <image> cat /var/log/gvmd/*` :
```
# docker exec -ti <image> cat /var/log/gvmd/* 
```
- Output from `docker exec -ti <image> cat /var/log/openvas/*` :
```
# docker exec -ti <image> cat /var/log/openvas/* 
```

**Additional context**
Add any other context about the problem here.
