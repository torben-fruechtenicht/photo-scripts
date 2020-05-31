#! /usr/bin/env bash

declare -r MONTHS="January!February!March!April!May!June!July!August!September!October!November!December"
declare -r DAYS_OF_MONTH="01!02!03!04!05!06!07!08!09!10!11!12!13!14!15!16!17!18!19!20!21!22!23!24!25!26!27!28!29!30!31"


run_yad() {
    local -r title=$1
    # adding a literal linebreak is the only way to force yad to actually add breaks
    local -r text="$2
    "
    shift 2

    local -r yad_options="--borders=10 --fixed --center"
    yad $yad_options --title="$title" --text="$text" "$@"
}

run_yad_selector_result_action_dialog() {
    local -r title=$1
    local -r selected_photos=$2
    local -r search_dir=$3
    local -r action_text=$4
    shift 4

    local -r selected_photos_count=$(echo "$photos" | wc -l)
    local -r selected_photos_list=$(__render_selected_photos_list "$(__remove_searchdir_from_photos_list "$selected_photos" "$search_dir")")
    local -r text="Selected $selected_photos_count photo(s) from $search_dir:\n\n$selected_photos_list\n$action_text"

    run_yad "$title" "$text" "$@"
}

__remove_searchdir_from_photos_list() {
    local -r list=$1
    local -r search_dir=$2

    echo "$list" | while read -r photo; do 
        echo ${photo#$search_dir/}
    done
}

__render_selected_photos_list() {
    local -r photos=$1
    # TODO if more than N in list, cut list after N entries (and maybe add a button to repeat the search)
    # TODO spreach across 2 columns if more than M entries in list
    #       https://unix.stackexchange.com/a/59292
    echo "$photos"
}


__lookup_memorized_value() {
    local -r saved_values_file=$1
    local -r fieldname=$2
    grep "^${fieldname}=" "$saved_values_file" | cut -d'=' -f2
}   

get_memorized_values_or_default() {
    local -r saved_values_file=$1
    local -r fieldname=$2
    local -r default=$3
  
    local value=$default

    if [[ -e $saved_values_file ]]; then
        value=$(__lookup_memorized_value "$saved_values_file" "$fieldname")
    fi

    echo "$value"
}

get_memorized_value_preselected_in_all_values_list() {
    local -r saved_values_file=$1
    local -r fieldname=$2
    local -r all_values=$3

    local values_optional_saved_preselected=$all_values

    if [[ -e $saved_values_file ]]; then
        local -r saved_value=$(__lookup_memorized_value "$saved_values_file" "$fieldname")
        if [[ -n $saved_value ]]; then
            values_optional_saved_preselected=$(echo "$all_values" | sed 's/\('"$saved_value"'\)/^\1/')
        fi
    fi

    echo "$values_optional_saved_preselected"
}

__count_char_in_string() {
    local -r c=$1
    local -r string=$2

    c_only=${string//[^$c]}
    echo ${#c_only}
}

memorize_form_combobox_values() {
    local -r saved_values_file=$1
    local -r fieldname=$2
    local -r current_value=$3
    local -r max_saved=${4-10}
    
    if grep -q "$fieldname=" "$saved_values_file"; then

        # get the saved values with any occurrence of $current_value already removed
        local -r saved_values=$(grep "$fieldname" "$saved_values_file" | cut -d'=' -f2 | sed -e 's/'"$current_value"'!\?//')
        if [[ -z $saved_values ]]; then
            sed -i -e 's/'"$fieldname"'=.*/'"$fieldname"'='"$current_value"'/' "$saved_values_file"
        else
            local -r values_count=$(( $(__count_char_in_string '!' "$saved_values") + 1 ))
            if (( $values_count < $max_saved )); then
                sed -i -e 's/'"$fieldname"'=.*/'"$fieldname"'='"$current_value"'!'"$saved_values"'/' "$saved_values_file"
            else 
                local -r saved_values_without_last=$(echo ${saved_values%!*})
                sed -i -e 's/'"$fieldname"'=.*/'"$fieldname"'='"$current_value"'!'"$saved_values_without_last"'/' "$saved_values_file"
            fi
        fi

    else
        echo "$fieldname=$current_value" >> "$saved_values_file"
    fi
}

memorize_form_value() {
    local -r saved_values_file=$1
    local -r fieldname=$2
    local -r value=$3

    if grep -q "$fieldname=" "$saved_values_file"; then
        sed -i -e 's/'"$fieldname"'=.*/'"$fieldname"'='"$value"'/' "$saved_values_file"
    else
        echo "$fieldname=$value" >> "$saved_values_file"
    fi    
}
