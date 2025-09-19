#!/bin/bash

if [ $# -eq 0 ]; then
    echo -e "e.g. ./firewalld_config.sh -t port1,port2 -u port1,port2 -i ip_addr1,ip_addr2"
    echo -e "./firewalld_config.sh"
    echo -e "\t\t\t-t tcp"
    echo -e "\t\t\t-u udp"
    echo -e "\t\t\t-i ip"
    echo -e "\t\t\t-w web"
    echo -e "\t\t\t-l lan"
    echo -e "\t\t\t-c container"
    echo -e "\t\t\t-d default"
    exit 0
fi

ARGS=$(getopt -o wlcdi:t:u: -n "$0" -- "$@")
if [ $? != 0 ]; then
    echo "Terminating..."
    exit 1
fi

eval set -- "${ARGS}"

# 停止 fail2ban
systemctl stop fail2ban

# 重置 firewalld
firewall-cmd --set-default-zone=public
firewall-cmd --permanent -- zone=public --remove-service=ssh || true
firewall-cmd --permanent -- zone=public --remove-port={1..65535}/tcp || true
firewall-cmd --permanent -- zone=public --remove-port={1..65535}/udp || true
firewall-cmd --permanent -- zone=public --remove-source=all || true

# 添加基础规则
firewall-cmd --permanent --add-service=ssh
firewall-cmd --permanent --add-icmp-block-inversion  # 允许 ICMP 请求
firewall-cmd --permanent --add-rich-rule='rule protocol value="ipv6-icmp" accept'  # IPv6 ICMP

# 默认拒绝所有入站连接（firewalld 默认 DROP）
# firewall-cmd 默认策略是 DROP，无需手动设置

# 处理参数
while true; do
    case "$1" in
        "-t")
            IFS=',' read -ra PORTS <<< "$2"
            for port in "${PORTS[@]}"; do
                firewall-cmd --permanent --add-port="$port/tcp"
            done
            shift 2
            ;;
        "-u")
            IFS=',' read -ra PORTS <<< "$2"
            for port in "${PORTS[@]}"; do
                firewall-cmd --permanent --add-port="$port/udp"
            done
            shift 2
            ;;
        "-i")
            IFS=',' read -ra IPS <<< "$2"
            for ip in "${IPS[@]}"; do
                if [[ $ip == *":"* ]]; then
                    firewall-cmd --permanent --add-rich-rule="rule family=\"ipv6\" source address=\"$ip\" accept"
                else
                    firewall-cmd --permanent --add-source="$ip"
                fi
            done
            shift 2
            ;;
        "-c")
            echo "Adding CONTAINER rules."
            firewall-cmd --permanent --add-source=172.16.0.0/14
            shift
            ;;
        "-w")
            echo "Adding WEB rules."
            firewall-cmd --permanent --add-service=http
            firewall-cmd --permanent --add-service=https
            shift
            ;;
        "-l")
            echo "Adding LAN rules."
            firewall-cmd --permanent --add-port=16999/udp
            firewall-cmd --permanent --add-source=192.168.99.0/24
            shift
            ;;
        "--")
            shift
            break
            ;;
        *)
            echo "Unknown error while processing options"
            exit 1
            ;;
    esac
done

# 允许本地回环
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="127.0.0.0/8" destination address="127.0.0.0/8" accept'

# 重新加载配置
firewall-cmd --reload

# 启动 fail2ban
systemctl start fail2ban

echo "Firewalld configuration updated successfully."
firewall-cmd --list-all

exit 0
