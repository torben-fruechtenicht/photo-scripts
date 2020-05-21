#! /usr/bin/env bash

__get_old_value() {
    local -r old_values_file=$1
    local -r name=$2
    grep "^${name}=" "$old_values_file" | cut -d'=' -f2
}    

declare -r __OLD_VALUES_DIR=$(readlink -m $HOME/.local/share/photo-scripts)

get_old_values_file() {
    local -r app_name=$1

    if ! [[ -d $__OLD_VALUES_DIR ]]; then
        mkdir --parents "$__OLD_VALUES_DIR"
    fi
    echo "$__OLD_VALUES_DIR/${app_name}_old_values"
}

old_values_or_default() {
    local -r old_values_file=$1
    local -r name=$2
    local -r default=$3
    

    local value=$default

    if [[ -e $old_values_file ]]; then
        value=$(__get_old_value "$OLD_VALUES_FILE" "$name")
    fi

    echo "$value"
}

old_value_preselected_in_list() {
    local -r old_values_file=$1
    local -r name=$2
    local -r all_values=$3

    local values_optional_old_preselected=$all_values

    if [[ -e $old_values_file ]]; then
        local -r old_value=$(__get_old_value "$OLD_VALUES_FILE" "$name")
        if [[ -n $old_value ]]; then
            values_optional_old_preselected=$(echo "$all_values" | sed 's/\('"$old_value"'\)/^\1/')
        fi
    fi

    echo "$values_optional_old_preselected"
}