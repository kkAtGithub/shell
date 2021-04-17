#!/bin/bash

apt install fail2ban -y

# wget -O /etc/fail2ban/jail.local https://raw.githubusercontent.com/kkAtGithub/shell/main/jail.local

cp jail.local /etc/fail2ban/jail.local

systemctl enable fail2ban && \
systemctl start fail2ban && \
systemctl status fail2ban

exit 0
