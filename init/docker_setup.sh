#!/bin/bash

# apt-get remove docker docker-engine docker.io containerd runc 

# apt-get purge -y docker-engine docker docker.io docker-ce 
# apt-get autoremove -y --purge docker-engine docker docker.io docker-ce 

# rm -rf /var/lib/docker /etc/docker
# groupdel docker
# rm -rf /var/run/docker.sock

apt-get update && \
apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y && \

ID=$(echo $(lsb_release -is) | awk '{print tolower($0)}')
MACHINE=$(uname -m)
if [[ $MACHINE =~ "x86_64" ]]; then
    ARCH="amd64"
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose
fi
if [[ $MACHINE =~ "aarch64" ]]; then
    ARCH="arm64"
    apt-get update
    apt-get install -y python3-pip libffi-dev
    pip3 install docker-compose
fi

curl -fsSL https://download.docker.com/linux/$ID/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \

echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$ID \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \

(apt-get update && \
apt-get install docker-ce docker-ce-cli containerd.io -y) || \
apt-get install docker-ce docker-ce-cli containerd.io -y
apt-get install docker-ce -y

if [ ! -d "/root/docker" ]; then
  mkdir /root/docker
else
  rm -r /root/docker/docker-*.sh
  crontab -l -u root | sed '/docker/d' | crontab -u root -
fi

cd /root/docker
echo "#!/bin/bash" > docker_up.sh && \
echo "docker-compose -f /root/docker/docker-compose.yml up --remove-orphans -d" >> docker_up.sh && \
echo "exit 0" >> docker_up.sh && \
chmod 700 docker_up.sh

echo "#!/bin/bash" > docker_down.sh && \
echo "docker-compose -f /root/docker/docker-compose.yml down --remove-orphans" >> docker_down.sh && \
echo "exit 0" >> docker_down.sh && \
chmod 700 docker_down.sh

if [ -f "/root/docker/docker-autostart.sh" ]; then
    rm /root/docker/docker-autostart.sh
    crontab -l -u root | sed '/docker/d' | crontab -u root -
fi

echo "[Unit]" > /etc/systemd/system/docker-stack.service && \
echo "Description=Docker stack" >> /etc/systemd/system/docker-stack.service && \
echo "Wants=network-online.target" >> /etc/systemd/system/docker-stack.service && \
echo "After=network.target" >> /etc/systemd/system/docker-stack.service && \
echo "" >> /etc/systemd/system/docker-stack.service && \
echo "[Service]" >> /etc/systemd/system/docker-stack.service && \
echo "Type=oneshot" >> /etc/systemd/system/docker-stack.service && \
echo "RemainAfterExit=yes" >> /etc/systemd/system/docker-stack.service && \
echo "ExecStart=/root/docker/docker_up.sh" >> /etc/systemd/system/docker-stack.service && \
echo "ExecReload=/root/docker/docker_up.sh" >> /etc/systemd/system/docker-stack.service && \
echo "ExecStop=/root/docker/docker_down.sh" >> /etc/systemd/system/docker-stack.service && \
echo "" >> /etc/systemd/system/docker-stack.service && \
echo "[Install]" >> /etc/systemd/system/docker-stack.service && \
echo "WantedBy=multi-user.target" >> /etc/systemd/system/docker-stack.service && \
echo "" >> /etc/systemd/system/docker-stack.service && \

systemctl daemon-reload && \
systemctl enable docker-stack.service 

exit 0
