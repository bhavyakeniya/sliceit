# Server hardening steps

| Step              | Impact                                              | Implemented?          |
| ------------------- |:----------------------------------------------------------:| ----------------------------:|
| Nginx on public subnet and application server on private subnet in a VPC when using AWS | App server would not be exposed publically | No, due to local setup. But ideally, this step should be implemented when deploying stack to AWS|
| Use authentication Key pair to log to your server | Using a private/public key is considered safe as compared to username/password combination | Yes |
| Use SSL certificates | Establishes encrypted link between server and client | No, due to local setup |
| Create a non-root user with sudo privileges | Prevents accidental root changes | Yes |
| Disable remote root login | Prevents an unauthorised user logging in with superuser privileges right away | Yes |
| Disallow SSH password authentication | Prevents anyone from logging in to the instance without having the SSH Key | Yes |
| Secure Shared Memory | Avoids Shared memory to be used in an attack against a running service | No, since we are running on containers and it requires system to be booted with systemd as init system (PID 1) |
| Configure Fail2ban | Fail2ban simply mitigates hacking attempts by utilizing IP tables to ban users trying to connect to your server depending on the failed login attempts | Yes |
| Allow SSH connection only from trusted IPs using Security Groups or firewalls | Restricted port 22 access | No, due to local setup |
| Keeping system packages up-to-date | Server gets periodic updates of fixes for security issues | Yes |
| Configure kernel parameters using sysctl.conf | Impact of the parameters are mentioned <a href="https://github.com/bhavyakeniya/sliceit/blob/master/ansible/roles/server-hardening/files/sysctl.conf">here</a> | Yes |
| Set Security Limits | Protects your system against fork bomb attacks | Yes |
| Enable nospoof | Protects against IP Spoofing | Yes |
| Enable SSH Login for Specific Users Only | Avoids Unauthorized ssh access | Yes |

# Hardening steps specific to nginx
| Step              | Impact                                              | Implemented?          |
| ------------------- |:----------------------------------------------------------:| ----------------------------:|
| Hide Details About Nginx (Disable server tokens) | Avoids information leakage | Yes |
| Enable X-XSS Protection | X-XSS protects the web server against cross-site scripting attacks | Yes |
| Disable Undesirable HTTP methods such as DELETE or TRACE | Avoids provision of stealing cookie information through cross-site tacking attacks | Yes |
| Prevent Clickjacking Attacks | Clickjacking attack entails hacker placing hidden link below legitimate button on site and the user unknowingly clicks on the attacker’s link causing malice. In most cases this is done using iframes. Hence in nginx, it’s advisable to insert X-FRAME-OPTIONS "SAMEORIGIN" in the header to limit the browser to load resources only from the web server | Yes |
| Disable weak SSL/TLS protocols | SSL 3, TLS 1.0, and TLS 1.1 is vulnerable, and we will allow only a strong TLS 1.2 and TLS 1.3 protocol | Yes, but no impact due to SSL off since it is a local setup |
| Disable weak cipher suites | Weak cipher suites may lead to vulnerability like a logjam | Yes |
| Secure Diffie-Hellman for TLS | Prevent weak key exchange exploits | Yes |
| Controlling Buffer Overflow Attacks | Avoids buffer overflow attacks | Yes |
| Block download agents | Blocking user-agents i.e. scanners, bots, and spammers who may be abusing your server | Yes |
| Block robots | Block robots called msnbot and scrapbot | Yes |
| Protection against MIME Sniffing | MIME sniffing can expose your site to attacks such as “drive-by downloads”. The ‘X-Content-Type-Options’ header counters this threat by ensuring only the MIME type provided by the server is honored | Yes |
| Control nginx timeouts to improve server performance | Improves server performance and cuts unnecssary long clients | Yes |
| Use SSL certificates | Establishes encrypted link between server and client | No, due to local setup |
