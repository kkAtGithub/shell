#!/bin/bash 

if [ -f "/root/shell/wireguard/wg99_postdown.sh" ];then
  sed -i '/PostDown = /d' /etc/wireguard/wg99.conf
  sed -i '5a\PostDown = /root/shell/wireguard/wg99_postdown.sh' /etc/wireguard/wg99.conf
fi
if [ -f "/root/shell/wireguard/wg99_predown.sh" ];then
  sed -i '/PreDown = /d' /etc/wireguard/wg99.conf
  sed -i '5a\PreDown = /root/shell/wireguard/wg99_predown.sh' /etc/wireguard/wg99.conf
fi
if [ -f "/root/shell/wireguard/wg99_postup.sh" ];then
  sed -i '/PostUp = /d' /etc/wireguard/wg99.conf
  sed -i '5a\PostUp = /root/shell/wireguard/wg99_postup.sh' /etc/wireguard/wg99.conf
fi
if [ -f "/root/shell/wireguard/wg99_preup.sh" ];then
  sed -i '/PreUp = /d' /etc/wireguard/wg99.conf
  sed -i '5a\PreUp = /root/shell/wireguard/wg99_preup.sh' /etc/wireguard/wg99.conf
fi

systemctl restart wg-quick@wg99.service

exit 0
