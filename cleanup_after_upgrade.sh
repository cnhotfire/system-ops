#!/bin/bash

set -e

echo "🧹 开始 Ubuntu 升级后的清理工作..."

echo "🔍 当前系统版本：$(lsb_release -d | cut -f2)"
echo "🔍 当前内核版本：$(uname -r)"

echo "📦 1. 自动清除无用依赖包..."
sudo apt autoremove --purge -y

echo "🧼 2. 清理 apt 缓存..."
sudo apt clean

echo "🧽 3. 删除卸载软件的残留配置文件..."
orphaned=$(dpkg -l | grep '^rc' | awk '{print $2}')
if [[ -n "$orphaned" ]]; then
  echo "$orphaned" | xargs -r sudo dpkg --purge
else
  echo "✅ 没有发现残留配置文件。"
fi

echo "📁 4. 检查并提示清理第三方 PPA 源..."
if ls /etc/apt/sources.list.d/*.list &>/dev/null; then
  echo "⚠️ 以下第三方源文件可能为旧版本残留，请手动检查："
  ls /etc/apt/sources.list.d/
else
  echo "✅ 未发现第三方源文件。"
fi

echo "🧯 5. 列出所有已安装内核，供你决定是否清理旧内核："
dpkg --list | grep linux-image | awk '{print $2}'

echo ""
echo "📌 当前运行的内核版本是：$(uname -r)"
echo "⚠️ 建议仅保留当前和上一个版本的内核，其余可以手动卸载："
echo "    sudo apt remove --purge linux-image-<版本号>"
echo ""

echo "🔁 6. 更新 grub 引导配置..."
sudo update-grub

echo "✅ 清理完成。建议重启系统确保新版本生效。"
