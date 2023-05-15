# challenge-3

Issue: cf-terraforming version 1.6 not found
Operating systems used: centos 7 & ubuntu trusty64

While attempting to use CF-Terraforming version 1.6, I encountered an issue where the version was not found after installation. I then attempted to install release v0.12.0 from the official repository, but the issue persisted. I then installed a lower version, v0.9.0, which was installed successfully.

Resolution attempt 1: Install preject required release 1.6.0

To resolve this issue, I downloaded and installed release v0.12.0 from the following link: https://github.com/cloudflare/cf-terraforming/releases. However, this did not fix the issue, and I continued to experience problems with CF-Terraforming.

I proceeded to install older version from the GitHub repository, which was version v0.9.0. this installation was successfull but didn't the script was not excuted as expected because of the follwoing:

- My original original script(original_script.sh)
Unexpected errors when listing resources, some of the commands where not found in v0.9.0 like zones and records
Empty resource listings

- With Modified script(modified_script.sh)

To resolve the zones and resource listing issues, I installed manually inputed the api for zones, I was able to:

Authenticate successfully
Pull cloudfare zone folder(empty no zones pulled)
Empty resource listings

In summary, due to the issues encountered when installing the latest cf-terraforming release v0.12.0, I had to install an older version v0.9.0 which allowed me to authenticate, and pull resources.

