#!/bin/bash

old_release="buster"
new_release="bullseye"


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

sed -i 's/$old_release/$new_release/g' /etc/apt/sources.list

apt-get update && \
apt-get autoremove -y && \
apt full-upgrade -y

apt purge $(dpkg -l | awk '/^rc/ { print $2 }')
