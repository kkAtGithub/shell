#!/bin/bash 

chmod 700 /root/shell/clone_repo.sh && \
/root/shell/clone_repo.sh && \
/root/shell/init/fail2ban_setup.sh && \
/root/shell/misc/iptables_config.sh -c

if [ -d "/root/backup/wireguard" ]; then
    apt-get update && \
    apt-get install net-tools wireguard-tools -y &&\
    /bin/cp -rf /root/backup/service/wg-quick@.service /lib/systemd/system/wg-quick@.service && \
    /bin/cp -rf /root/backup/wireguard /etc/wireguard && \
    systemctl daemon-reload
    
    if [ -f "/etc/wireguard/wg99.conf" ]; then
        systemctl enable wg-quick@wg99 && \
        systemctl start wg-quick@wg99
    fi
fi

/bin/cp -rf /root/backup/conf/hosts /etc/hosts

if [ -f "/root/backup/service/docker.service" ]; then
    /root/shell/init/docker_setup.sh && \
    /bin/cp -rf /root/backup/service/docker.service /lib/systemd/system/docker.service && \
    systemctl daemon-reload && \
    systemctl restart docker.service && \
    /root/docker/docker-autostart.sh
fi

apt-get autoremove -y

{ crontab -l -u root; echo "@reboot /root/docker/docker-autostart.sh > /dev/null 2>&1"; } | crontab -u root -
{ crontab -l -u root; echo "0 3 * * * docker system prune --force > /dev/null 2>&1"; } | crontab -u root -
{ crontab -l -u root; echo "0 4 * * * /root/docker/docker-autostart.sh > /dev/null 2>&1"; } | crontab -u root -

exit 0
