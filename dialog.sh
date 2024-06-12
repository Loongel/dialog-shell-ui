#!/bin/bash
(

# 检查脚本运行目录,并存入script_dir,供各功能模块引用
script_dir=$(dirname "$(readlink -f "$0")")
if [ "$(pwd)" != "$script_dir" ]; then
    echo "错误：脚本必须在其所在目录下运行。当前目录：$(pwd)，脚本目录：$script_dir"
    # exit 1
fi
cd $script_dir

# 调试模式，1为开启，0为关闭, 2为详细日志（单条命令）
debug_mode=1
#echo "脚本文件夹：$script_dir"
#read -p "Type 'yes' to continue: " input

# 检查项目权限
sudo chown $(whoami) -R $script_dir

# 日志路径
log_file="$script_dir/logs/dialog-shell-ui.log"

# 加载公共库
source lib/utils.sh
source lib/interaction.sh


# 主循环，处理用户交互并根据配置文件动态加载和执行功能
function main {
    while true; do
        present_menu
    done
}

main

)