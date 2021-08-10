#!/bin/bash 

/bin/cp -rf /etc/wireguard /root/wireguard
/bin/cp -rf /lib/systemd/system/wg-quick@.service /root/service/wg-quick@.service
/bin/cp -rf /lib/systemd/system/docker.service /root/service/docker.service

exit 0
