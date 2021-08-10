#!/bin/bash

apt install fail2ban inetutils-syslogd -y

/bin/cp -rf /root/shell/misc/jail.local /etc/fail2ban/jail.local

systemctl enable fail2ban && \
systemctl restart fail2ban

exit 0
