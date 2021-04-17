#!/bin/bash

cd /root/shell

export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890

wget -O docker_setup.sh https://raw.githubusercontent.com/kkAtGithub/shell/main/docker_setup.sh && \
chmod 700 docker_setup.sh
wget -O fail2ban_setup.sh https://raw.githubusercontent.com/kkAtGithub/shell/main/fail2ban_setup.sh && \
chmod 700 fail2ban_setup.sh
wget -O wireguard_config.sh https://raw.githubusercontent.com/kkAtGithub/shell/main/wireguard_config.sh && \
chmod 700 wireguard_config.sh
wget -O iptables_config.sh https://raw.githubusercontent.com/kkAtGithub/shell/main/iptables_config.sh && \
chmod 700 iptables_config.sh
wget -O clone_repo.sh https://raw.githubusercontent.com/kkAtGithub/shell/main/clone_repo.sh && \
chmod 700 clone_repo.sh

exit 0
