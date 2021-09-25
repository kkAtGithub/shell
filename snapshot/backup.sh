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

if [ -d "/etc/docker" ]; then
    IP_WG99=$(ifconfig wg99|grep inet|awk '{print $2}'|tr -d "addr:")
    EXEC_START=$(cat /lib/systemd/system/docker.service | grep "ExecStart")
    sed -i "s#$EXEC_START#$EXEC_START -H tcp://$IP_WG99:2375#g" /lib/systemd/system/docker.service && \
    /bin/cp -rf /lib/systemd/system/docker.service /root/backup/service/docker.service
fi

/bin/cp -rf /etc/hosts /root/backup/conf/hosts

exit 0
