#!/bin/bash

iptables -L
ip6tables -L

iptables -F
ip6tables -F

iptables -A INPUT -p icmp -j ACCEPT
ip6tables -A INPUT -p icmpv6 -j ACCEPT

iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
ip6tables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

while getopts ":t:u:i:h" optname
do
    case "$optname" in
      "t")
        array=(${OPTARG//,/ })
        for port in ${array[@]}
        do 
            iptables -A INPUT -p tcp --dport $port -j ACCEPT
            ip6tables -A INPUT -p tcp --dport $port -j ACCEPT
        done
        ;;
      "u")
        array=(${OPTARG//,/ })
        for port in ${array[@]}
        do 
            iptables -A INPUT -p udp --dport $port -j ACCEPT
            ip6tables -A INPUT -p udp --dport $port -j ACCEPT
        done
        ;;
      "i")
        array=(${OPTARG//,/ })
        for ip in ${array[@]}
        do 
            if [[ $ip =~ ":" ]]
            then
                ip6tables -A INPUT -s $ip -j ACCEPT
            else
                iptables -A INPUT -s $ip -j ACCEPT
            fi
        done
        ;;
      "h")
        echo "Example: -t 22,80,443 (tcp) -u 53 (udp) -ip 127.0.0.1"
        ;;
      ":")
        echo "No argument value for option $OPTARG"
        ;;
      "?")
        echo "Unknown option $OPTARG"
        ;;
      *)
        echo "Unknown error while processing options"
        ;;
    esac
    # echo "option index is $OPTIND"
done

iptables -P INPUT DROP
ip6tables -P INPUT DROP

iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

netfilter-persistent save || apt-get install iptables-persistent

iptables -L
ip6tables -L
