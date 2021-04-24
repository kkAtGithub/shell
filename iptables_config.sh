#!/bin/bash

if [ $# -eq 0 ]; then
    echo -e "e.g. ./iptables_config.sh -t port1,port2 -u port1,port2 -i ip_addr1,ip_addr2"
    echo -e "./iptables_config.sh"
    echo -e "\t\t\t-t tcp"
    echo -e "\t\t\t-u udp"
    echo -e "\t\t\t-i ip"
    exit 0
fi


iptables -L
ip6tables -L

iptables -F
ip6tables -F

iptables -A INPUT -p icmp -j ACCEPT
ip6tables -A INPUT -p icmpv6 -j ACCEPT

iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
ip6tables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

while getopts ":t:u:i:" optname
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
      ":")
        echo "No argument value for option $OPTARG"
        exit 0
        ;;
      "?")
        echo "Unknown option $OPTARG"
        exit 0
        ;;
      *)
        echo "Unknown error while processing options"
        exit 0
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

exit 0
