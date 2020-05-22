#! /usr/bin/env bash

__get_old_value() {
    local -r old_values_file=$1
    local -r name=$2
    grep "^${name}=" "$old_values_file" | cut -d'=' -f2
}   

get_old_values_file() {
    local -r app_name=$1
    local -r old_values_file_dir=$(readlink -m $HOME/.local/share/photo-scripts)
    if ! [[ -d $old_values_file_dir ]]; then
        mkdir --parents "$old_values_file_dir"
    fi
    echo "$old_values_file_dir/${app_name}_old_values"
}

declare -r MONTHS_INCL_EMPTY_VALUE="!Jan!Feb!Mar!Apr!May!June!July!Aug!Sep!Oct!Nov!Dec"
declare -r DAYS_OF_MONTH_INCL_EMPTY_VALUE="!01!02!03!04!05!06!07!08!09!10!11!12!13!14!15!16!17!18!19!20!21!22!23!24!25!26!27!28!29!30!31"

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

__count_char_in_string() {
    local -r c=$1
    local -r string=$2

    c_only=${string//[^$c]}
    echo ${#c_only}
}

save_cb_value() {
    local -r old_values_file=$1
    local -r name=$2
    local -r value=$3
    local -r max_saved=${4-10}
    
    if grep -q "$name=" "$old_values_file"; then

        # get the old values with any occurrence of $value already removed
        local -r old_values=$(grep "$name" "$old_values_file" | cut -d'=' -f2 | sed -e 's/'"$value"'!\?//')
        if [[ -z $old_values ]]; then
            sed -i -e 's/'"$name"'=.*/'"$name"'='"$value"'/' "$old_values_file"
        else
            local -r values_count=$(( $(__count_char_in_string '!' "$old_values") + 1 ))
            if (( $values_count < $max_saved )); then
                sed -i -e 's/'"$name"'=.*/'"$name"'='"$value"'!'"$old_values"'/' "$old_values_file"
            else 
                local -r old_values_without_last=$(echo ${old_values%!*})
                sed -i -e 's/'"$name"'=.*/'"$name"'='"$value"'!'"$old_values_without_last"'/' "$old_values_file"
            fi
        fi

    else
        echo "$name=$value" >> "$old_values_file"
    fi
}

save_single_value() {
    local -r old_values_file=$1
    local -r name=$2
    local -r value=$3

    if grep -q "$name=" "$old_values_file"; then
        sed -i -e 's/'"$name"'=.\+/'"$name"'='"$value"'/' "$old_values_file"
    else
        echo "$name=$value" >> "$old_values_file"
    fi    
}