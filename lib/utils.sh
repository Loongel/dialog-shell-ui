# lib/utils.sh

# 确保日志文件存在
if [ ! -f "$log_file" ]; then
    sudo touch "$log_file"
    sudo chmod 666 "$log_file"
else
    echo "" > $log_file
fi

# 开启详细日志
[ "$debug_mode" -eq 2 ] && exec 2>>$log_file && set -x

function log {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$log_file"
}

# function load_config {
#     declare -gA function_map
#     for conf_file in conf/*.conf; do
#         source "$conf_file"
#         function_map["$name"]="$conf_file"
#     done
# }

function check_function_status {
    eval "$check_command" >> $log_file 2>&1
    local result=${PIPESTATUS[0]}
    local rs=$(( $result == 0 ? 1 : 0 ))  # 根据执行结果输出1成功或0失败
    log "check_function_status() > [$name]: check_command - $check_command， result: $rs"
    echo $rs 
}

function show_debug_info {
    dialog --title "调试信息" --textbox "$log_file" 20 100
}

function execute_function {
    local name=$1
    local action=$2  # "enable" or "disable"
    local command_var=$3  # cmd_var="${msg}_cmd"

    local before_status=$(check_function_status)
    log "execute_function().1 > [$name]: exec - $action, before - $before_status"
    if { [ "$action" == "enable" ] && [ "$before_status" -eq 0 ]; } || 
       { [ "$action" == "disable" ] && [ "$before_status" -eq 1 ]; }; then
        eval "${!command_var}"
        local status=$?
        log "execute_function().2 > [$name]: exec_return - $status "
        local after_status=$(check_function_status)
        local result_msg=$([ "$before_status" != "$after_status" ] && echo "success" || echo "fail")
        log "execute_function().3 > [$name]: exec - $action, before - $before_status, after - $after_status, result - $result_msg "
        return $status
    else
        log "execute_function().4 > [$name]: $action - none need to change"
    fi
}
