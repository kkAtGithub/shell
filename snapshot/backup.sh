#!/bin/bash 

if [ ! -d "/root/backup" ]; then
    mkdir /root/backup
    mkdir /root/backup/conf
    mkdir /root/backup/service
fi

if [ -d "/etc/wireguard" ]; then
    /bin/cp -rf /etc/wireguard /root/backup/wireguard
    /bin/cp -rf /lib/systemd/system/wg-quick@.service /root/backup/service/wg-quick@.service
fi

/bin/cp -rf /lib/systemd/system/docker.service /root/backup/service/docker.service
/bin/cp -rf /etc/hosts /root/backup/conf/hosts
/bin/cp -rf /etc/ssh/sshd_config /root/backup/conf/sshd_config

exit 0
