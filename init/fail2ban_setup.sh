#!/bin/bash

apt-get install fail2ban inetutils-syslogd -y

/bin/cp -rf /root/shell/fail2ban/ /etc/fail2ban/

systemctl enable fail2ban && \
systemctl restart fail2ban

exit 0
