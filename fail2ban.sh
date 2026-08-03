#!/bin/bash
# ==============================================================================
# Fail2ban Minimal Installer
# Debian 12 Pure System
# SSH Protection + Journald Limit
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

echo "[INFO] 创建 Fail2ban SSH 配置..."
mkdir -p /etc/fail2ban/jail.d
cat >/etc/fail2ban/jail.d/sshd.local <<EOF
[DEFAULT]
backend = systemd
ignoreip = 127.0.0.1/8 ::1
findtime = 10m
bantime = 72h
maxretry = 3

[sshd]
enabled = true
port = $SSH_PORT
EOF

echo "[INFO] 设置 journald 日志限制..."
mkdir -p /etc/systemd/journald.conf.d
cat >/etc/systemd/journald.conf.d/99-log-limit.conf <<EOF
[Journal]
SystemMaxUse=1G
SystemMaxFileSize=50M
MaxRetentionSec=180day
Compress=yes
EOF
systemctl restart systemd-journald

echo "[INFO] 检测 Fail2ban 配置..."
fail2ban-client -t

echo "[INFO] 启动 Fail2ban..."
systemctl enable fail2ban
systemctl restart fail2ban
sleep 2

if systemctl is-active --quiet fail2ban; then
    echo
    echo "================================="
    echo " Fail2ban 安装完成"
    echo "================================="
    echo "SSH端口 : $SSH_PORT"
    echo "失败次数 : 3"
    echo "检测时间 : 10分钟"
    echo "封禁时间 : 72小时"
    echo "日志保留 : 180天 / 最大1G"
    echo
    echo "状态: fail2ban-client status sshd"
    echo "封禁IP: fail2ban-client get sshd banip"
    echo "================================="
else
    journalctl -u fail2ban -n 50 --no-pager
    exit 1
fi
