#!/bin/bash -e

# apt-get remove docker docker-engine docker.io containerd runc 

apt-get update && \

apt-get install \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release -y && \

curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \

apt-get update && \

apt-get install docker-ce docker-ce-cli containerd.io -y && \

curl -L "https://github.com/docker/compose/releases/download/1.29.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
chmod +x /usr/local/bin/docker-compose

mkdir /root/docker
cd /root/docker
echo "#!/bin/sh -e" > docker-autostart.sh
echo "docker-compose -f /root/docker/docker-compose.yml up --remove-orphans -d" >> docker-autostart.sh
echo "exit 0" >> docker-autostart.sh
chmod 700 docker-autostart.sh

