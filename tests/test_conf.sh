#!/bin/bash

# 确保脚本在tests目录下执行
script_dir="$(dirname "$(readlink -f "$0")")/.."
cd $script_dir

# 日志文件路径
log_test_file="$script_dir/logs/test-conf.log"

# 导入公共库
debug_mode=1 # 调试模式，1为开启，0为关闭, 2为详细日志（单条命令）
log_file="$script_dir/logs/dialog-shell-ui.log"
source lib/utils.sh

# 确保日志文件存在
if [ ! -f "$log_test_file" ]; then
    touch "$log_test_file"
    chmod 666 "$log_test_file"
else
    echo "" > $log_test_file
fi

log_and_echo() {
    echo -e "$1" | tee -a "$log_test_file"
}

##### 测试脚本
# 开始测试
log_and_echo "开始测试配置文件..."
log_and_echo "$script_dir"

# 测试每个.conf文件
for conf_file in conf/*.conf; do
    source "$conf_file"
    log_and_echo "测试 $conf_file" 
    test_rs1=1; test_rs2=0; test_rs3=0; test_rs4=0
    # 检查必要的字段
    if [[ -z $name || -z $enable_command || -z $disable_command || -z $check_command || -z $description ]]; then
        log_and_echo "\t[错误]: [$conf_file] 缺少必要的字段"
        test_rs1=0
        continue
    fi
    
    # 测试 disable 命令
    eval "$disable_command"
    check_status=$(check_function_status)
    if [[ $check_status -eq 1 ]]; then
        log_and_echo "\t[错误]: [$name] 禁用失败" 
        log_and_echo "\tdisable_command: $disable_command"
    else
        log_and_echo "\t[$name] 禁用成功" 
        test_rs2=1
    fi

    # 测试 enable 命令
    eval "$enable_command"
    check_status=$(check_function_status)
    if [[ $check_status -eq 0 ]]; then
        log_and_echo "\t[错误]: [$name] 启用失败" 
        log_and_echo "\tenable_command: $enable_command"
        read -p "      waiting for debug. pess any key to continue." input
    else
        log_and_echo "\t[$name] 启用成功" 
        test_rs3=1
    fi

    # 再次测试 disable 命令
    eval "$disable_command"
    check_status=$(check_function_status)
    if [[ $check_status -eq 1 ]]; then
        log_and_echo "\t[错误]: [$name] 最终禁用失败" 
        log_and_echo "\tdisable_command: $disable_command"
    else
        log_and_echo "\t[$name] 最终禁用成功" 
        test_rs4=1
    fi

    if [ "$test_rs1" -eq 1 ] && [ "$test_rs2" -eq 1 ] && [ "$test_rs3" -eq 1 ] && [ "$test_rs4" -eq 1 ]; then
        log_and_echo "[$conf_file]: 测试 - 通过" 
    else
        log_and_echo "[$conf_file]: 测试 - 失败" 
    fi

done

log_and_echo "所有配置文件测试完成。" 
