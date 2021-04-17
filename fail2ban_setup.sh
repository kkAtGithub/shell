#!/bin/bash

apt install fail2ban -y

wget -O /etc/fail2ban/jail.local https://raw.githubusercontent.com/kkAtGithub/shell/main/jail.local

systemctl enable fail2ban && \
systemctl restart fail2ban && \
systemctl status fail2ban
tail -f /var/log/fail2ban.log

exit 0
