#!/bin/bash

/root/shell/snapshot/backup.sh

apt-get update && \
apt-get full-upgrade -y && \
#apt-get install apt-forktracer -y && \
apt-get autoremove -y

#ndp=$(apt-forktracer | sort | awk '{print $1}')

#for package in $ndp
#do
#    apt-get remove $package -y
#done

#apt-get remove apt-forktracer -y
#apt-get autoremove -y

leftover=$(find /etc -name '*.dpkg-*' -o -name '*.ucf-*' -o -name '*.merge-error')

for file in $leftover
do 
    rm $file
done

sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list.d/*

sed -i '/bullseye/d' /etc/apt/sources.list && \
echo "deb http://deb.debian.org/debian/ bookworm contrib main non-free non-free-firmware" >> /etc/apt/sources.list && \
echo "# deb-src http://deb.debian.org/debian/ bookworm contrib main non-free non-free-firmware" >> /etc/apt/sources.list && \
echo "deb http://deb.debian.org/debian/ bookworm-updates contrib main non-free non-free-firmware" >> /etc/apt/sources.list && \
echo "# deb-src http://deb.debian.org/debian/ bookworm-updates contrib main non-free non-free-firmware" >> /etc/apt/sources.list && \
echo "deb http://deb.debian.org/debian/ bookworm-proposed-updates contrib main non-free non-free-firmware" >> /etc/apt/sources.list && \
echo "# deb-src http://deb.debian.org/debian/ bookworm-proposed-updates contrib main non-free non-free-firmware" >> /etc/apt/sources.list && \
echo "deb http://deb.debian.org/debian/ bookworm-backports contrib main non-free non-free-firmware" >> /etc/apt/sources.list && \
echo "# deb-src http://deb.debian.org/debian/ bookworm-backports contrib main non-free non-free-firmware" >> /etc/apt/sources.list && \
echo "deb http://deb.debian.org/debian-security/ bookworm-security contrib main non-free non-free-firmware" >> /etc/apt/sources.list && \
echo "# deb-src http://deb.debian.org/debian-security/ bookworm-security contrib main non-free non-free-firmware" >> /etc/apt/sources.list

apt-get update && \
apt-get autoremove -y && \
apt-get full-upgrade -y

apt-get install linux-image-amd64 -y && \
apt-get install linux-headers-amd64 -y && \
update-grub

apt-get purge $(dpkg -l | awk '/^rc/ { print $2 }') -y && \
apt-get autoremove -y

#/root/shell/snapshot/restore.sh
apt-get autoremove -y

exit 0
