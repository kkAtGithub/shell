#!/bin/bash 

if [ ! -d "/root/backup" ]; then
    mkdir /root/backup
    mkdir /root/backup/conf
    mkdir /root/backup/service
fi

if [ -d "/root/.adguard" ]; then
    /bin/cp -rf /opt/AdGuardHome/AdGuardHome.yaml /root/.adguard
    /bin/cp -rf /etc/nginx/nginx.conf /root/.adguard/nginx
fi

if [ -d "/etc/wireguard" ]; then
    rm -rf /root/backup/wireguard
    /bin/cp -rf /etc/wireguard /root/backup/
#     /bin/cp -rf /lib/systemd/system/wg-quick@.service /root/backup/service/wg-quick@.service
fi

if [ -d "/etc/docker" ]; then
    /bin/cp -rf /etc/systemd/system/docker.service /root/backup/service/docker.service
fi

/bin/cp -rf /etc/hosts /root/backup/conf/hosts

exit 0
