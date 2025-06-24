#!/bin/bash

set -e

SCREEN_NAME="ubuntu-upgrade"

echo "📦 检查 screen 是否安装..."
if ! command -v screen &>/dev/null; then
  echo "🔧 未检测到 screen，正在安装..."
  sudo apt update && sudo apt install -y screen
fi

echo "🖥️ 启动 screen 会话：$SCREEN_NAME 并运行升级流程..."

screen -S "$SCREEN_NAME" -dm bash -c '
  set -e
  echo "🔍 检查当前版本..."
  CURRENT_VERSION=$(lsb_release -rs)

  if [[ \"$CURRENT_VERSION\" != \"22.04\" ]]; then
    echo \"❌ 当前系统版本为 $CURRENT_VERSION，非 22.04，脚本退出。\"
    exit 1
  fi

  echo "📦 更新系统并清理旧软件包..."
  sudo apt update && sudo apt upgrade -y && sudo apt dist-upgrade -y
  sudo apt autoremove --purge -y

  echo "🛠️ 安装 update-manager-core（如未安装）..."
  sudo apt install -y update-manager-core

  echo "🔧 修改配置以允许 LTS 升级..."
  sudo sed -i "s/^Prompt=.*/Prompt=lts/" /etc/update-manager/release-upgrades

  echo "🚀 启动升级流程到 Ubuntu 24.04..."
  sudo do-release-upgrade -f DistUpgradeViewNonInteractive -d

  echo ""
  echo "⚠️  请在 screen 中手动执行：sudo do-release-upgrade"
  echo "💡  或使用非交互方式：sudo do-release-upgrade -f DistUpgradeViewNonInteractive -d"
  exec bash
'

echo "✅ 准备工作已完成，升级环境已在 screen 中启动。"
echo "👉 请输入以下命令进入 screen 并开始升级："
echo "    screen -r $SCREEN_NAME"
