#!/bin/bash

cd /root/shell

rm /root/shell/*

wget -O docker_setup.sh https://raw.githubusercontent.com/kkAtGithub/shell/main/docker_setup.sh
wget -O fail2ban_setup.sh https://raw.githubusercontent.com/kkAtGithub/shell/main/fail2ban_setup.sh
wget -O wireguard_config.sh https://raw.githubusercontent.com/kkAtGithub/shell/main/wireguard_config.sh
wget -O iptables_config.sh https://raw.githubusercontent.com/kkAtGithub/shell/main/iptables_config.sh
wget -O clone_repo.sh https://raw.githubusercontent.com/kkAtGithub/shell/main/clone_repo.sh

chmod 700 -R /root/shell

exit 0
