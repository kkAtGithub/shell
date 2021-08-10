#!/bin/bash 

iptables -A INPUT -p udp --dport 16999 -j ACCEPT
ip6tables -A INPUT -p udp --dport 16999 -j ACCEPT
iptables -A INPUT -s 192.168.99.0/24 -j ACCEPT

exit 0
