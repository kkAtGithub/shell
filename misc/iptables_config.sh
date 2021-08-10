#!/bin/bash

if [ $# -eq 0 ]; then
    echo -e "e.g. ./iptables_config.sh -t port1,port2 -u port1,port2 -i ip_addr1,ip_addr2"
    echo -e "./iptables_config.sh"
    echo -e "\t\t\t-t tcp"
    echo -e "\t\t\t-u udp"
    echo -e "\t\t\t-i ip"
    echo -e "\t\t\t-w web"
    echo -e "\t\t\t-l lan"
    echo -e "\t\t\t-c container"
    echo -e "\t\t\t-d default"
    exit 0
fi

ARGS=`getopt -o wlcdi:t:u: -n "$0" -- "$@"`
if [ $? != 0 ]; then
    echo "Terminating..."
    exit 1
fi

eval set -- "${ARGS}"

systemctl stop fail2ban

iptables -L
ip6tables -L

iptables -F
ip6tables -F

iptables -P INPUT DROP
ip6tables -P INPUT DROP

iptables -P FORWARD DROP
ip6tables -P FORWARD DROP

iptables -A INPUT -p icmp -j ACCEPT
ip6tables -A INPUT -p icmpv6 -j ACCEPT

iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
ip6tables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

iptables -A INPUT -p tcp --dport 22 -j ACCEPT
ip6tables -A INPUT -p tcp --dport 22 -j ACCEPT

while true
do
    case "$1" in
      "-t")
        array=(${2//,/ })
        for port in ${array[@]}
        do 
            iptables -A INPUT -p tcp --dport $port -j ACCEPT
            ip6tables -A INPUT -p tcp --dport $port -j ACCEPT
        done
        shift 2
        ;;
      "-u")
        array=(${2//,/ })
        for port in ${array[@]}
        do 
            iptables -A INPUT -p udp --dport $port -j ACCEPT
            ip6tables -A INPUT -p udp --dport $port -j ACCEPT
        done
        shift 2
        ;;
      "-i")
        array=(${2//,/ })
        for ip in ${array[@]}
        do 
            if [[ $ip =~ ":" ]]
            then
                ip6tables -A INPUT -s $ip -j ACCEPT
            else
                iptables -A INPUT -s $ip -j ACCEPT
            fi
        done
        shift 2
        ;;
      "-d")
        echo "Adding DEFAULT rules."
        
        shift
        ;;
      "-c")
        echo "Adding CONTAINER rules."
        iptables -A INPUT -s 172.18.0.0/24 -j ACCEPT
        shift
        ;;
      "-w")
        echo "Adding WEB rules."
        iptables -A INPUT -p tcp --dport 80 -j ACCEPT
        ip6tables -A INPUT -p tcp --dport 80 -j ACCEPT
        iptables -A INPUT -p tcp --dport 443 -j ACCEPT
        ip6tables -A INPUT -p tcp --dport 443 -j ACCEPT
        shift
        ;;
      "-l")
        echo "Adding LAN rules."
        iptables -A INPUT -p udp --dport 16999 -j ACCEPT
        ip6tables -A INPUT -p udp --dport 16999 -j ACCEPT
        iptables -A INPUT -s 192.168.99.0/24 -j ACCEPT
        shift
        ;;
      # ":")
      #   echo "No argument value for option $OPTARG"
      #   exit 0
      #   ;;
      # "?")
      #   echo "Unknown option $OPTARG"
      #   exit 0
      #   ;;
      --)
        shift
        break
        ;;
      *)
        echo "Unknown error while processing options"
        exit 0
        ;;
    esac
    # echo "option index is $OPTIND"
done

iptables -A INPUT -s 127.0.0.0/8 -d 127.0.0.0/8 -j ACCEPT

iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

netfilter-persistent save || apt-get install iptables-persistent -y

iptables -L
ip6tables -L

systemctl start fail2ban

exit 0
