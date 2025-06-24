#!/bin/bash

set -e

SCREEN_NAME="ubuntu-upgrade-20to22"

echo "⚠️  警告：在继续之前，请确保已备份重要数据！"
echo "     升级可能导致数据丢失或系统不稳定[2,4](@ref)"
echo "====================================================="

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
    CODENAME=$(lsb_release -cs)

    if [[ "$CURRENT_VERSION" != "20.04" ]]; then
        echo "❌ 当前系统版本为 $CURRENT_VERSION，非 20.04，无法升级到22.04。脚本退出。"
        exit 1
    fi

    echo "✅ 当前系统版本为 Ubuntu 20.04 ($CODENAME)，符合升级条件[1,2](@ref)"

    echo "📦 更新系统并清理旧软件包..."
    sudo apt update && sudo apt upgrade -y && sudo apt dist-upgrade -y
    sudo apt autoremove --purge -y
    sudo apt clean

    echo "🛠️ 安装 update-manager-core（如未安装）[4](@ref)..."
    sudo apt install -y update-manager-core

    echo "🔧 修改配置以允许 LTS 升级..."
    sudo sed -i "s/^Prompt=.*/Prompt=lts/" /etc/update-manager/release-upgrades

    echo "🚀 开始升级到 Ubuntu 22.04 (Jammy Jellyfish)..."
    echo "⚠️  注意：升级过程可能需要较长时间，请保持网络连接稳定"
    echo "     在SSH环境下升级存在风险，建议保持会话活跃[4](@ref)"
    echo "-----------------------------------------------------"
    
    # 执行实际升级, 静默操作
    sudo do-release-upgrade -f DistUpgradeViewNonInteractive -d
    
    echo ""
    echo "✅ 升级完成！请确认升级结果："
    echo "   检查版本命令: lsb_release -a"
    echo "   重启系统命令: sudo reboot"
    echo "-----------------------------------------------------"
    echo "💡 升级后注意事项："
    echo "   1. Firefox已转为snap包，检查Firefox是否正常运行[2,5](@ref)"
    echo "   2. 运行 sudo apt update && sudo apt upgrade 更新所有包"
    echo "   3. 检查应用程序兼容性，特别是自定义内核模块[4](@ref)"
    exec bash
'

echo "✅ 升级环境已在 screen 会话 [$SCREEN_NAME] 中准备就绪！"
echo "👉 请使用以下命令进入 screen 会话并开始升级："
echo "    screen -r $SCREEN_NAME"
echo ""
echo "💡 操作指南："
echo "   1. 进入会话后，系统将自动执行升级前准备"
echo "   2. 升级过程中请遵循提示操作（输入'y'确认等）"
echo "   3. 按 Ctrl+A+D 可暂时退出会话（升级在后台继续）"
echo "   4. 使用 screen -r $SCREEN_NAME 重新连接会话"
echo ""
echo "⚠️  重要提示：升级过程中请勿强制中断或关闭终端！"
echo "====================================================="
