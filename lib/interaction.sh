# lib/interaction.sh

function present_menu {
    local IFS=$'\n'
    local options=()
    local option_name=""
    local option_names=""
    for conf_file in conf/*.conf; do
        source "$conf_file"
        option_name="$(basename "$conf_file" .conf)"
        option_names+="$option_name "
        options+=("$option_name" "$(echo $description)" "$(convert_checklist)")
    done

    exec 3>&1
    selections=$(dialog \
        --backtitle "功能管理" \
        --title "配置选项" \
        --clear \
        --cancel-label "退出" \
        --checklist "选择需要启用的功能:" 15 70 4 \
        "${options[@]}" \
        2>&1 1>&3)
    exit_status=$?
    exec 3>&-

    case $exit_status in
        0)
            process_selections "$selections" "$option_names"
            [ "$debug_mode" -eq 1 ] && show_debug_info
            ;;
        1 | 255)
            clear; echo "程序已退出。"; exit
            ;;
    esac

}

function convert_checklist {
    local function_status=$(check_function_status "$name")
    local result=$([ "$function_status" -eq 1 ] && echo "on" || echo "off")
    log "convert_checklist() > $name - $result"
    echo $result
}

function process_selections {
    local selections=$1
    local options=$2
    local action command_var

    # 分割选择的字符串，处理每个选项
    IFS=' ' read -ra selected_options <<< "$selections"
    IFS=' ' read -ra all_options <<< "$options"
    log "process_selections().1 > selected_options: $selected_options"
    for option in "${all_options[@]}"; do       
        source "conf/${option}.conf"
        log "process_selections().2 > selected_options: \"${selected_options[*]}\", option: \"$option\""
        if [[ "${selected_options[*]}" =~ "$option" ]]; then
            action="enable"
        else
            action="disable"
        fi
        command_var="${action}_command"
        #log "process_selections() > $option - $action"
        log "process_selections().3 > [$name]: action - $action, check_cmd: $check_command, cmd: \"${!command_var}\""
        execute_function "$name" "$action" "$command_var"
    done
}
