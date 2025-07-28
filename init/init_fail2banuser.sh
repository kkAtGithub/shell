#!/bin/bash

# 可自定义部分
USERNAME="fail2banuser"
ALLOWED_SUBNET="172.16.0.0/12"
FORCE_COMMAND="/usr/local/bin/fail2ban-wrapper.sh"
ALLOWED_CMD="/usr/bin/fail2ban-client"
TARGET_JAIL="frps-kk"

echo "[+] 创建用户 $USERNAME ..."
sudo adduser --disabled-password --shell /usr/sbin/nologin --gecos "" $USERNAME

echo "[+] 设置 sudo 权限，只允许运行 fail2ban-client ..."
echo "$USERNAME ALL=(ALL) NOPASSWD: $ALLOWED_CMD" | sudo tee /etc/sudoers.d/$USERNAME > /dev/null
sudo chmod 440 /etc/sudoers.d/$USERNAME

echo "[+] 创建受限 wrapper 脚本 ..."
sudo tee $FORCE_COMMAND > /dev/null <<EOF
#!/bin/bash
if [ -z "$1" ]; then
  echo "[Fail2Ban Restricted Shell]"
  read -p "Enter IP to unban from jail [frps-kk]: " ip
else
  ip="$1"
fi

# 简单 IPv4 校验
if [[ ! "$ip" =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]]; then
  echo "Invalid IP format"
  exit 1
fi

logger -t fail2ban-unban "User $USER requested unban for IP $ip in jail frps-kk"
sudo /usr/bin/fail2ban-client set frps-kk unbanip "$ip"
EOF

sudo chmod +x $FORCE_COMMAND

echo "[+] 配置 SSH 限制：只允许从 $ALLOWED_SUBNET 登录该用户 ..."
sudo tee -a /etc/ssh/sshd_config > /dev/null <<EOF

Match User $USERNAME Address $ALLOWED_SUBNET
    PasswordAuthentication no
    AuthorizedKeysFile /etc/ssh/fail2banuser_authorized_keys
    ForceCommand /usr/local/bin/fail2ban-wrapper.sh
    PermitTTY no
    AllowTcpForwarding no
    X11Forwarding no
EOF

echo "[+] 重启 SSH 服务 ..."
sudo systemctl restart sshd

echo "[+] 完成。用户 $USERNAME 只能从 $ALLOWED_SUBNET 登录并运行 fail2ban unban 指令。"
