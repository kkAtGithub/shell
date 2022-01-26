#!/bin/bash 

chmod 700 /root/shell/clone_repo.sh && \
/root/shell/clone_repo.sh && \
/root/shell/init/fail2ban_setup.sh && \
/root/shell/misc/iptables_config.sh

if [ -d "/root/.adguard" ]; then
    /root/shell/init/adguard_setup.sh
    /bin/cp -rf /root/.adguard /opt/AdGuardHome/AdGuardHome.yaml
    /bin/cp -rf /root/.adguard/nginx /etc/nginx/nginx.conf
fi

if [ -d "/root/backup/wireguard" ]; then
    apt-get update && \
    apt-get install net-tools wireguard-tools -y
#     /bin/cp -rf /root/backup/service/wg-quick@.service /lib/systemd/system/wg-quick@.service && \
    /bin/cp -rf /root/backup/wireguard /etc/ && \
    systemctl daemon-reload
    
    if [ -f "/etc/wireguard/wg99.conf" ]; then
        systemctl enable wg-quick@wg99 && \
        systemctl start wg-quick@wg99
    fi
fi

if [ -f "/root/backup/conf/hosts" ]; then
    /bin/cp -rf /root/backup/conf/hosts /etc/
fi

if [ -f "/root/backup/service/docker.service" ]; then
#     IP_WG99=$(ifconfig wg99|grep inet|awk '{print $2}'|tr -d "addr:")
#     EXEC_START=$(cat /etc/systemd/system/docker.service | grep "ExecStart")
    /root/shell/init/docker_setup.sh
    /bin/cp -rf /root/backup/service/docker.service /etc/systemd/system/docker.service
#     if [[ ! $EXEC_START =~ $IP_WG99 ]]; then
#         sed -i "s#$EXEC_START#$EXEC_START -H tcp://$IP_WG99:2375#g" /etc/systemd/system/docker.service
#     fi
    systemctl daemon-reload && \
    systemctl restart docker.service && \
    systemctl restart docker-stack.service
    /root/shell/misc/iptables_config.sh -c
fi

journalctl --vacuum-time=1w
apt-get autoremove -y

exit 0
