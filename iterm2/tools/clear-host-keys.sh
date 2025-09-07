#!/bin/bash

# SSH主机密钥清除工具
# 用于清除服务器重装或还原后的旧主机密钥

echo "==============================================="
echo "            SSH主机密钥清除工具"
echo "==============================================="
echo

# 检查参数
if [ $# -eq 0 ]; then
    echo "使用方法: $0 <主机IP或域名> [端口号]"
    echo
    echo "示例:"
    echo "  $0 8.130.78.8"
    echo "  $0 example.com 2222"
    echo
    exit 1
fi

HOST=$1
PORT=${2:-22}  # 默认端口22

echo "目标服务器: $HOST"
echo "端口: $PORT"
echo

# 显示当前known_hosts中的相关记录
echo "正在检查现有主机密钥..."
if grep -q "^$HOST" ~/.ssh/known_hosts 2>/dev/null; then
    echo "发现以下相关记录:"
    grep "^$HOST" ~/.ssh/known_hosts | nl
    echo
else
    echo "在 ~/.ssh/known_hosts 中未找到 $HOST 的记录"
    echo "可能已经被清除或从未连接过"
    exit 0
fi

# 确认操作
read -p "是否要清除 $HOST 的所有主机密钥? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "操作已取消"
    exit 0
fi

# 备份known_hosts文件
echo "正在备份 ~/.ssh/known_hosts..."
cp ~/.ssh/known_hosts ~/.ssh/known_hosts.backup.$(date +%Y%m%d_%H%M%S)

# 清除主机密钥
echo "正在清除 $HOST 的主机密钥..."
ssh-keygen -R "$HOST" 2>/dev/null

# 如果指定了非标准端口，也清除带端口的记录
if [ "$PORT" != "22" ]; then
    echo "正在清除带端口的记录 [$HOST]:$PORT ..."
    ssh-keygen -R "[$HOST]:$PORT" 2>/dev/null
fi

echo
echo "✅ 主机密钥清除完成!"
echo
echo "现在可以重新连接到服务器:"
echo "  ssh -p $PORT root@$HOST"
echo
echo "或使用你的连接脚本重新建立连接"
echo

# 显示备份文件位置
echo "原始 known_hosts 文件已备份至:"
ls -la ~/.ssh/known_hosts.backup.* 2>/dev/null | tail -1 | awk '{print "  " $9 " (" $5 " bytes, " $6 " " $7 " " $8 ")"}'