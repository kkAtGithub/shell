#!/bin/bash 

if [ ! -d "/root/backup" ]; then
    mkdir /root/backup
    mkdir /root/backup/conf
    mkdir /root/backup/service
fi

if [ -d "/etc/wireguard" ]; then
    rm -rf /root/backup/wireguard
    /bin/cp -rf /etc/wireguard /root/backup/
    /bin/cp -rf /lib/systemd/system/wg-quick@.service /root/backup/service/wg-quick@.service
fi

if [ -d "/etc/docker" ]; then
    /bin/cp -rf /lib/systemd/system/docker.service /root/backup/service/docker.service
fi

/bin/cp -rf /etc/hosts /root/backup/conf/hosts

exit 0
