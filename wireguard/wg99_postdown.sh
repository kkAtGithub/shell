#!/bin/bash 

iptables -D INPUT -p udp --dport 16999 -j ACCEPT
ip6tables -D INPUT -p udp --dport 16999 -j ACCEPT
iptables -D INPUT -s 192.168.99.0/24 -j ACCEPT

exit 0
