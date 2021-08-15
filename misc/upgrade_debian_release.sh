#!/bin/bash

apt-get update && \
apt-get full-upgrade -y && \
apt-get install apt-forktracer -y && \
apt-get autoremove -y

ndp=$(apt-forktracer | sort | awk '{print $1}')

for package in $ndp
do
    apt-get remove $package -y
done

apt-get remove apt-forktracer -y

apt-get autoremove -y

leftover=$(find /etc -name '*.dpkg-*' -o -name '*.ucf-*' -o -name '*.merge-error')

for file in $leftover
do 
    rm $file
done

rm /etc/apt/sources.list.d/*

sed -i '/buster/d' /etc/apt/sources.list && \
echo "deb http://deb.debian.org/debian bullseye main contrib non-free" >> /etc/apt/sources.list && \
echo "deb http://deb.debian.org/debian bullseye-updates main contrib non-free" >> /etc/apt/sources.list && \
echo "deb http://security.debian.org/debian-security bullseye-security main" >> /etc/apt/sources.list && \
echo "deb http://ftp.debian.org/debian bullseye-backports main contrib non-free" >> /etc/apt/sources.list

apt-get update && \
apt-get autoremove -y && \
apt-get full-upgrade -y

apt purge $(dpkg -l | awk '/^rc/ { print $2 }')
