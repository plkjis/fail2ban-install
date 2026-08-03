#!/bin/bash
# ==============================================================================
# Fail2ban Modern Minimal Installer (Debian 12 / Ubuntu 22+)
# FangYi Edition — Simple, Stable, Auto-Detect SSH Port
# ==============================================================================

set -e

echo "[INFO] 检测 SSH 端口..."
SSH_PORT=$(sshd -T 2>/dev/null | awk '/^port /{print $2}' | head -1)
[ -z "$SSH_PORT" ] && SSH_PORT=22
echo "[INFO] 检测到 SSH 端口: $SSH_PORT"

echo "[INFO] 更新软件源..."
apt-get update -y

echo "[INFO] 安装 Fail2ban..."
apt-get install -y fail2ban

echo "[INFO] 创建最小化 SSH 防护配置..."
mkdir -p /etc/fail2ban/jail.d

cat >/etc/fail2ban/jail.d/sshd.local <<EOF
[sshd]
enabled = true
port = $SSH_PORT
maxretry = 3
bantime = 72h
EOF

echo "[INFO] 启动并启用 Fail2ban..."
systemctl enable fail2ban
systemctl restart fail2ban

echo "[INFO] 检查状态..."
sleep 1
systemctl status fail2ban --no-pager

echo
echo "[OK] Fail2ban 已安装并启用 SSH 防护。"
echo "[OK] 配置：最多尝试 3 次 → 封禁 72 小时"
echo "[OK] 自动检测 SSH 端口: $SSH_PORT"
echo "[OK] 查看状态：fail2ban-client status sshd"
echo "[OK] 查看封禁 IP：fail2ban-client get sshd banip"
