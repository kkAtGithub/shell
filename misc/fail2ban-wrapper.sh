#!/bin/bash
if [ -z "$1" ]; then
  echo "[Fail2Ban Restricted Shell]"
  read -p "Enter IP to unban from jail [frps-kk]: " ip
else
  ip="$1"
fi

# 简单 IPv4 校验
if [[ ! "$ip" =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]]; then
  echo "Invalid IP format"
  exit 1
fi

logger -t fail2ban-unban "User $USER requested unban for IP $ip in jail frps-kk"
sudo /usr/bin/fail2ban-client set frps-kk unbanip "$ip"
