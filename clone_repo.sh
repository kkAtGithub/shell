#!/bin/bash

cd /root/shell

curl -o docker_setup.sh https://raw.githubusercontent.com/kkAtGithub/shell/main/docker_setup.sh && \
chmod 700 docker_setup.sh
curl -o fail2ban_setup.sh https://raw.githubusercontent.com/kkAtGithub/shell/main/fail2ban_setup.sh && \
chmod 700 fail2ban_setup.sh
curl -o wireguard_config.sh https://raw.githubusercontent.com/kkAtGithub/shell/main/wireguard_config.sh && \
chmod 700 wireguard_config.sh
curl -o iptables_config.sh https://raw.githubusercontent.com/kkAtGithub/shell/main/iptables_config.sh && \
chmod 700 iptables_config.sh
curl -o clone_repo.sh https://raw.githubusercontent.com/kkAtGithub/shell/main/clone_repo.sh && \
chmod 700 clone_repo.sh

exit 0