#!/bin/bash

MODE=$1

apt-get update && \
apt-get install net-tools iproute2 openresolv dnsutils -y && \
apt-get install wireguard-tools -y && \
modprobe wireguard && \
lsmod | grep wireguard

apt-get update && \
apt-get install curl lsb-release -y

rm -rf /root/wgcf
mkdir /root/wgcf && \
cd /root/wgcf

curl -fsSL git.io/wgcf.sh | bash

wgcf register && wgcf generate && \
sed -i '/AllowedIPs = 0.0.0.0\/0/d' wgcf-profile.conf && \
sed -i '/AllowedIPs = ::\/0/d' wgcf-profile.conf

if [ "$MODE" == "-4" ];then
    sed -i '6a\PostDown = iptables -P FORWARD DROP' wgcf-profile.conf && \
    sed -i '6a\PreUp = iptables -P FORWARD ACCEPT' wgcf-profile.conf && \
    sed -i '/Endpoint = /i AllowedIPs = 0.0.0.0\/0' wgcf-profile.conf && \
    sed -i 's/engage.cloudflareclient.com/[2606:4700:d0::a29f:c001]/' wgcf-profile.conf && \
    sed -i 's/DNS = 1.1.1.1/DNS = 2620:119:35::35,2001:4860:4860::8888,2606:4700:4700::1111/' wgcf-profile.conf
    
    /bin/cp -rf wgcf-profile.conf /etc/wireguard/wgcfv4.conf && \
    systemctl enable wg-quick@wgcfv4 && \
    systemctl start wg-quick@wgcfv4
    
    curl -4 ip.p3terx.com
fi

if [ "$MODE" == "-6" ];then
    sed -i '6a\PostDown = ip6tables -P FORWARD DROP' wgcf-profile.conf && \
    sed -i '6a\PreUp = ip6tables -P FORWARD ACCEPT' wgcf-profile.conf && \
    sed -i '/Endpoint = /i AllowedIPs = ::\/0' wgcf-profile.conf && \
    sed -i 's/engage.cloudflareclient.com/162.159.192.1/' wgcf-profile.conf && \
    sed -i 's/DNS = 1.1.1.1/DNS = 208.67.222.222,8.8.8.8,1.1.1.1/' wgcf-profile.conf
    
    /bin/cp -rf wgcf-profile.conf /etc/wireguard/wgcfv6.conf && \
    systemctl enable wg-quick@wgcfv6 && \
    systemctl start wg-quick@wgcfv6
    
    curl -6 ip.p3terx.com
fi

exit 0
