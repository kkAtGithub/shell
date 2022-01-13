#!/bin/bash

cd /root/shell/rclone

curl https://rclone.org/install.sh | bash

echo "[Unit]" > /etc/systemd/system/rclone-mount.service && \
echo "Description=Rclone mount" >> /etc/systemd/system/rclone-mount.service && \
echo "Wants=network-online.target" >> /etc/systemd/system/rclone-mount.service && \
echo "After=network.target" >> /etc/systemd/system/rclone-mount.service && \
echo "" >> /etc/systemd/system/rclone-mount.service && \
echo "[Service]" >> /etc/systemd/system/rclone-mount.service && \
echo "Type=oneshot" >> /etc/systemd/system/rclone-mount.service && \
echo "RemainAfterExit=yes" >> /etc/systemd/system/rclone-mount.service && \
echo "ExecStart=/root/shell/rclone/rclone_mount.sh" >> /etc/systemd/system/rclone-mount.service && \
echo "ExecReload=/root/shell/rclone/rclone_umount.sh && /root/shell/rclone/rclone_mount.sh" >> /etc/systemd/system/rclone-mount.service && \
echo "ExecStop=/root/shell/rclone/rclone_umount.sh" >> /etc/systemd/system/rclone-mount.service && \
echo "" >> /etc/systemd/system/rclone-mount.service && \
echo "[Install]" >> /etc/systemd/system/rclone-mount.service && \
echo "WantedBy=multi-user.target" >> /etc/systemd/system/rclone-mount.service && \
echo "" >> /etc/systemd/system/rclone-mount.service && \

systemctl daemon-reload

chmod 700 rclone_*.sh

exit 0
