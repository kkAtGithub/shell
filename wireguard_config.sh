#!/bin/bash

MODE=$1

echo "deb http://deb.debian.org/debian $(lsb_release -sc)-backports main" | tee /etc/apt/sources.list.d/backports.list
apt update

apt install net-tools iproute2 openresolv dnsutils -y
apt install wireguard-tools --no-install-recommends

apt install wireguard-dkms -y
modprobe wireguard
lsmod | grep wireguard

apt update
apt install curl lsb-release -y

mkdir /root/wireguard
cd /root/wireguard

curl -fsSL git.io/wgcf.sh | bash

wgcf register && wgcf generate

if [ "$MODE" == "--ipv4" ];then
    sed -i 's/engage.cloudflareclient.com/162.159.192.1/' wgcf-profile.conf
    sed -i '/AllowedIPs = 0.0.0.0\/0/d' wgcf-profile.conf
    sed -i 's/DNS = 1.1.1.1/DNS = 208.67.222.222,8.8.8.8,1.1.1.1/' wgcf-profile.conf
fi

if [ "$MODE" == "--ipv6" ];then
    sed -i 's/engage.cloudflareclient.com/[2606:4700:d0::a29f:c001]/' wgcf-profile.conf
    sed -i '/AllowedIPs = ::\/0/d' wgcf-profile.conf
    sed -i 's/DNS = 1.1.1.1/DNS = 2620:119:35::35,2001:4860:4860::8888,2606:4700:4700::1111/' wgcf-profile.conf
fi

cp wgcf-profile.conf /etc/wireguard/wgcf.conf && \
wg-quick up wgcf

if [ "$MODE" == "--ipv4" ];then
    curl -6 ip.p3terx.com
fi

if [ "$MODE" == "--ipv6" ];then
    curl -4 ip.p3terx.com
fi

wg-quick down wgcf

systemctl start wg-quick@wgcf && \
systemctl enable wg-quick@wgcf
