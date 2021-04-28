#!/bin/bash

cd /root/shell

curl -o frp_update.sh https://raw.githubusercontent.com/kkAtGithub/shell/main/frp_update.sh && \
chmod 700 frp_update.sh
curl -o docker_setup.sh https://raw.githubusercontent.com/kkAtGithub/shell/main/docker_setup.sh && \
chmod 700 docker_setup.sh
curl -o fail2ban_setup.sh https://raw.githubusercontent.com/kkAtGithub/shell/main/fail2ban_setup.sh && \
chmod 700 fail2ban_setup.sh
curl -o wgcf_config.sh https://raw.githubusercontent.com/kkAtGithub/shell/main/wgcf_config.sh && \
chmod 700 wgcf_config.sh
curl -o iptables_config.sh https://raw.githubusercontent.com/kkAtGithub/shell/main/iptables_config.sh && \
chmod 700 iptables_config.sh
curl -o clone_repo.sh https://raw.githubusercontent.com/kkAtGithub/shell/main/clone_repo.sh && \
chmod 700 clone_repo.sh


exit 0
