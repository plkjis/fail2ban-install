#!/bin/bash
# ==============================================================================
# Fail2ban Minimal Installer
# Debian 12 Pure System
# SSH Protection Only
# ==============================================================================

set -e

echo "[INFO] 检测 SSH 端口..."

SSH_PORT=$(sshd -T 2>/dev/null | awk '/^port /{print $2}' | head -1)

[ -z "$SSH_PORT" ] && SSH_PORT=22

echo "[INFO] SSH端口: $SSH_PORT"


echo "[INFO] 更新软件源..."

apt-get update -y


echo "[INFO] 安装 Fail2ban..."

apt-get install -y fail2ban python3-systemd


echo "[INFO] 创建 SSH 防护配置..."

mkdir -p /etc/fail2ban/jail.d


cat >/etc/fail2ban/jail.d/sshd.local <<EOF
[sshd]
enabled = true
backend = systemd
port = $SSH_PORT
maxretry = 3
findtime = 10m
bantime = 72h
EOF


echo "[INFO] 检测配置..."

fail2ban-client -t


echo "[INFO] 启动 Fail2ban..."

systemctl enable fail2ban

systemctl restart fail2ban


sleep 2


echo "[INFO] 当前状态..."

systemctl is-active --quiet fail2ban || {
    journalctl -u fail2ban -n 50 --no-pager
    exit 1
}


echo
echo "================================="
echo " Fail2ban 安装完成"
echo "================================="
echo "SSH端口 : $SSH_PORT"
echo "失败次数 : 3"
echo "检测时间 : 10分钟"
echo "封禁时间 : 72小时"
echo
echo "查看状态:"
echo "fail2ban-client status sshd"
echo
echo "查看封禁IP:"
echo "fail2ban-client get sshd banip"
echo "================================="
