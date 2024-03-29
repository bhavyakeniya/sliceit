FROM ubuntu:bionic

RUN apt-get update && apt-get install -y ssh ansible sudo locales
RUN mkdir /var/run/sshd

# Setup ansible user
RUN useradd ansible -s /bin/bash
RUN mkdir -p /home/ansible/.ssh/
RUN chmod 0700 /home/ansible/.ssh/
COPY ssh_config /home/ansible/.ssh/config
COPY ansible /home/ansible/.ssh/id_rsa
RUN chmod 600 /home/ansible/.ssh/id_rsa
COPY ansible.pub /home/ansible/.ssh/id_rsa.pub
COPY ansible.pub /home/ansible/.ssh/authorized_keys
RUN chown -R ansible:ansible /home/ansible/
RUN echo "ansible ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Following lines taken from: https://github.com/tianon/dockerfiles
#
# The Expat/MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

COPY init-fake.conf /etc/init/fake-container-events.conf
RUN rm /usr/sbin/policy-rc.d; rm /sbin/initctl; dpkg-divert --rename --remove /sbin/initctl

RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8

# remove some pointless services
RUN /usr/sbin/update-rc.d -f ondemand remove; \
  for f in \
    /etc/init/u*.conf \
    /etc/init/mounted-dev.conf \
    /etc/init/mounted-proc.conf \
    /etc/init/mounted-run.conf \
    /etc/init/mounted-tmp.conf \
    /etc/init/mounted-var.conf \
    /etc/init/hostname.conf \
    /etc/init/networking.conf \
    /etc/init/tty*.conf \
    /etc/init/plymouth*.conf \
    /etc/init/hwclock*.conf \
    /etc/init/module*.conf\
  ; do \
    dpkg-divert --local --rename --add "$f"; \
  done; \
  echo '# /lib/init/fstab: cleared out for bare-bones Docker' > /lib/init/fstab

COPY start.sh /home/ansible

RUN mkdir -p /home/ansible/ansible-code

WORKDIR /home/ansible/ansible-code

EXPOSE 22

CMD ["/home/ansible/start.sh"]
